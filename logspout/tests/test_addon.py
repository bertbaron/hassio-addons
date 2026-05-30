import json
import os
import shutil
import subprocess
import time
import unittest
import uuid
from pathlib import Path


ADDON_DIR = Path(__file__).resolve().parents[1]
IMAGE_TAG = f"logspout-addon-test:{uuid.uuid4().hex[:12]}"


def docker_socket_path() -> str:
    docker_host = os.environ.get("DOCKER_HOST", "")
    if docker_host.startswith("unix://"):
        return docker_host[len("unix://") :]
    if docker_host.startswith("tcp://"):
        raise unittest.SkipTest("Docker daemon is not exposed over a unix socket")
    return "/var/run/docker.sock"


def run(command: list[str], cwd: Path | None = None, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        cwd=cwd,
        check=check,
        text=True,
        capture_output=True,
    )


def docker(*args: str, cwd: Path | None = None, check: bool = True) -> subprocess.CompletedProcess[str]:
    return run(["docker", *args], cwd=cwd, check=check)


def wait_for(predicate, timeout: float, description: str) -> None:
    deadline = time.time() + timeout
    last_error = None
    while time.time() < deadline:
        try:
            if predicate():
                return
        except AssertionError as exc:
            last_error = exc
        time.sleep(1)
    if last_error is not None:
        raise last_error
    raise AssertionError(f"timed out waiting for {description}")


class AddonRuntimeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.socket_path = docker_socket_path()
        docker("build", "--tag", IMAGE_TAG, ".", cwd=ADDON_DIR, check=True)

    @classmethod
    def tearDownClass(cls) -> None:
        docker("image", "rm", "-f", IMAGE_TAG, check=False)

    def setUp(self) -> None:
        self.created_containers: list[str] = []
        self.created_networks: list[str] = []

    def tearDown(self) -> None:
        for container in reversed(self.created_containers):
            docker("rm", "-f", container, check=False)
        for network in reversed(self.created_networks):
            docker("network", "rm", network, check=False)

    def test_forwards_logs_with_hostname_and_strips_ansi(self) -> None:
        marker = f"marker-{uuid.uuid4().hex}"
        network = self.create_network("logspout-test-net")
        sink = self.run_container(
            "logspout-test-sink",
            [
                "--network",
                network,
                "-e",
                "LOGSPOUT=ignore",
                "alpine:3.22",
                "sh",
                "-c",
                "while true; do nc -lp 1514; done",
            ],
        )
        options_dir = Path(self.make_options_dir(
            {
                "routes": ["syslog+tcp://logspout-test-sink:1514"],
                "hostname": "ha-test-host",
                "strip_ansi": True,
            }
        ))
        addon = self.run_container(
            "logspout-test-addon",
            [
                "--network",
                network,
                "-v",
                f"{options_dir}:/data",
                "-v",
                f"{self.socket_path}:/run/docker.sock",
                IMAGE_TAG,
            ],
        )

        wait_for(
            lambda: "# logspout" in self.logs(addon),
            30,
            "addon startup log",
        )

        docker(
            "run",
            "--rm",
            "--name",
            "logspout-test-producer",
            "--network",
            network,
            "alpine:3.22",
            "sh",
            "-c",
            f"sleep 1; printf '\\033[31m{marker}\\033[0m\\n'; sleep 1",
        )

        def assert_sink_output() -> bool:
            output = self.logs(sink)
            for line in output.splitlines():
                if marker in line:
                    self.assertIn("ha-test-host", line)
                    self.assertNotIn("\x1b[", line)
                    return True
            return False

        wait_for(assert_sink_output, 30, "forwarded syslog line")

    def test_fails_clearly_without_docker_socket(self) -> None:
        options_dir = Path(self.make_options_dir({"routes": ["raw+tcp://example:1514"]}))
        container = self.run_container(
            "logspout-test-no-socket",
            [
                "-v",
                f"{options_dir}:/data",
                IMAGE_TAG,
            ],
        )

        wait_for(lambda: self.container_status(container) == "exited", 20, "launcher failure")
        self.assertIn("docker socket not found", self.logs(container))

    def test_fails_clearly_for_invalid_options_json(self) -> None:
        options_dir = Path(self.make_options_dir(None, raw="{"))
        container = self.run_container(
            "logspout-test-invalid-config",
            [
                "-v",
                f"{options_dir}:/data",
                "-v",
                f"{self.socket_path}:/run/docker.sock",
                IMAGE_TAG,
            ],
        )

        wait_for(lambda: self.container_status(container) == "exited", 20, "invalid config failure")
        self.assertIn("decode /data/options.json", self.logs(container))

    def create_network(self, prefix: str) -> str:
        name = f"{prefix}-{uuid.uuid4().hex[:8]}"
        docker("network", "create", name)
        self.created_networks.append(name)
        return name

    def run_container(self, name: str, args: list[str]) -> str:
        docker("run", "-d", "--name", name, *args)
        self.created_containers.append(name)
        return name

    def make_options_dir(self, payload: dict | None, raw: str | None = None) -> str:
        options_dir = ADDON_DIR / "tests" / f"tmp-{uuid.uuid4().hex[:8]}"
        options_dir.mkdir(parents=True, exist_ok=False)
        self.addCleanup(lambda: shutil.rmtree(options_dir, ignore_errors=True))
        options_path = options_dir / "options.json"
        if raw is not None:
            options_path.write_text(raw, encoding="utf-8")
        else:
            options_path.write_text(json.dumps(payload), encoding="utf-8")
        return str(options_dir)

    def logs(self, container: str) -> str:
        result = docker("logs", container, check=False)
        return (result.stdout or "") + (result.stderr or "")

    def container_status(self, container: str) -> str:
        result = docker("inspect", "-f", "{{.State.Status}}", container)
        return result.stdout.strip()


if __name__ == "__main__":
    unittest.main()
