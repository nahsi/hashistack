variables {
  versions = {
    loki = "2.3.0"
  }
}

job "loki" {
  datacenters = ["dc1"]
  type        = "service"

  group "loki" {
    ephemeral_disk {}
    network {
      mode = "bridge"
      port "loki" {
        to = 3100
        static = 3100
      }
    }

    service {
      name = "loki"
      port = "loki"

      check {
        name     = "Loki HTTP"
        type     = "http"
        path     = "/ready"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "loki" {
      driver = "docker"
      user   = "nobody"

      resources {
        memory = 64
      }

      config {
        image = "grafana/loki:${var.versions.loki}"

        ports = [
          "loki"
        ]

        args = [
          "-config.file=/local/loki.yml"
        ]
      }

      template {
        data = file("loki.yml")
        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/loki.yml"
      }
    }
  }
}
