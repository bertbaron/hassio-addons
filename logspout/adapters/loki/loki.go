package loki

import (
	"fmt"
	"io/ioutil"
	"os"
	"os/signal"
	"strings"
	"time"

	"github.com/gliderlabs/logspout/cfg"
	"github.com/gliderlabs/logspout/router"
	lokiclient "github.com/livepeer/loki-client/client"
	"github.com/livepeer/loki-client/model"
)

var hostname string

func getHostname() string {
	content, err := ioutil.ReadFile("/etc/host_hostname")
	if err == nil && len(content) > 0 {
		hostname = strings.TrimRight(string(content), "\r\n")
	} else {
		hostname = cfg.GetEnvDefault("SYSLOG_HOSTNAME", "{{.Container.Config.Hostname}}")
	}
	return hostname
}

func init() {
	hostname = getHostname()
	router.AdapterFactories.Register(NewLokiAdapter, "loki")
}

// LokiAdapter is an adapter that streams logs to Loki.
type LokiAdapter struct {
	route  *router.Route
	client *lokiclient.Client
}

func logger(v ...interface{}) {
	fmt.Println(v...)
}

// NewLokiAdapter creates a LokiAdapter.
func NewLokiAdapter(route *router.Route) (router.LogAdapter, error) {
	baseLabels := model.LabelSet{}
	lokiURL := "http://" + route.Address + "/api/prom/push"
	fmt.Printf("Using Loki url: %s\n", lokiURL)
	client, err := lokiclient.NewWithDefaults(lokiURL, baseLabels, logger)
	if err != nil {
		return nil, err
	}
	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt)
	go waitExit(client, c)

	return &LokiAdapter{
		route:  route,
		client: client,
	}, nil
}

// Stream implements the router.LogAdapter interface.
func (a *LokiAdapter) Stream(logstream chan *router.Message) {
	defer a.client.Stop()

	lastLineTime := time.Now()
	for m := range logstream {
		labels := model.LabelSet{
			"nodename":       hostname,
			"container_id":   m.Container.ID,
			"container_name": m.Container.Name[1:],
			"image_id":       m.Container.Image,
			"image_name":     m.Container.Config.Image,
			"command":        strings.Join(m.Container.Config.Cmd[:], " "),
			"created":        fmt.Sprintf("%s", m.Container.Created),
		}

		line := strings.TrimSpace(m.Data)
		if len(line) > 0 {
			a.client.Handle(labels, lastLineTime, line)
		}
	}
}

func waitExit(client *lokiclient.Client, c chan os.Signal) {
	<-c
	client.Stop()
}
