variables {
  versions = {
    tempo = "1.1.0"
  }
}

job "tempo" {
  datacenters = ["dc1"]
  type        = "service"

  group "tempo" {
    ephemeral_disk {}
    network {
      mode = "bridge"
      port "tempo" {
        to = 3400
        static = 3400
      }
    }

    service {
      name = "tempo"
      port = "tempo"

      check {
        name     = "Tempo HTTP"
        type     = "http"
        path     = "/ready"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "tempo" {
      driver = "docker"
      user = "nobody"

      resources {
        memory = 64
      }

      config {
        image = "grafana/tempo:${var.versions.tempo}"

        ports = [
          "tempo"
        ]

        args = [
          "-config.file=/local/tempo.yml"
        ]
      }

      template {
        data = file("tempo.yml")
        destination = "local/tempo.yml"
      }
    }
  }
}
