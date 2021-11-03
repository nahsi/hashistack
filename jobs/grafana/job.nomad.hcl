variables {
  versions = {
    grafana = "8.2.1"
  }
}

job "grafana" {
  datacenters = ["dc1"]
  type        = "service"

  group "grafana" {
    network {
      mode = "bridge"
      port "grafana" {
        to = 3000
        static = 3000
      }
    }

    service {
      name = "grafana"
      port = "grafana"

      check {
        name     = "Grafana HTTP"
        type     = "http"
        path     = "/api/health"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "grafana" {
      driver = "docker"
      user = "nobody"

      resources {
        memory = 64
      }

      env {
        GF_PATHS_CONFIG="/local/grafana/grafana.ini"
        GF_PATHS_PROVISIONING="/local/grafana/provisioning"
      }

      config {
        image = "grafana/grafana:${var.versions.grafana}"

        ports = [
          "grafana"
        ]
      }

      template {
        data = file("grafana.ini")
        destination = "local/grafana/grafana.ini"
      }

      template {
        data = file("provisioning/datasources.yml")
        destination = "local/grafana/provisioning/datasources/datasources.yml"
      }

      template {
        data = file("provisioning/dashboards.yml")
        destination = "local/grafana/provisioning/dashboards/dashboards.yml"
      }

      template {
        data = file("dashboards/dummy.json")
        left_delimiter  = "[["
        right_delimiter  = "]]"
        destination = "local/dashboards/dummy.json"
      }
    }
  }
}
