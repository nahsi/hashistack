variables {
  versions = {
    prometheus = "2.30.3"
  }
}

job "prometheus" {
  datacenters = ["dc1"]
  type        = "service"

  group "prometheus" {
    ephemeral_disk {}
    network {
      mode = "bridge"
      port "prometheus" {
        to = 9090
        static = 9090
      }
    }

    service {
      name = "prometheus"
      port = "prometheus"

      check {
        name     = "Prometheus HTTP"
        type     = "http"
        path     = "/-/healthy"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "prometheus" {
      driver = "docker"
      user = "nobody"

      resources {
        memory = 64
      }

      config {
        image = "prom/prometheus:v${var.versions.prometheus}"

        ports = [
          "prometheus"
        ]

        args = [
          "--web.listen-address=0.0.0.0:9090",
          "--config.file=/local/prometheus.yml",
          "--storage.tsdb.path=/alloc/data/prometheus"
        ]
      }

      template {
        data = file("prometheus.yml")
        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/prometheus.yml"
      }
    }
  }
}
