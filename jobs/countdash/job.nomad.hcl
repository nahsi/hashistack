job "countdash" {
  datacenters = ["dc1"]
  type = "service"

  group "api" {
    network {
      mode = "bridge"
      port "envoy" {
        to = 9102
      }
    }

    service {
      name = "count-api"
      port = 9001

      meta {
        dashboard = "F8eFiYKnk"
      }

      connect {
        sidecar_service {}
      }
    }

    service {
      name = "envoy"
      port = "envoy"
    }

    task "api" {
      driver = "docker"

      resources {
        memory = 32
      }

      config {
        image = "hashicorpnomad/counter-api:v3"
      }
    }
  }

  group "dashboard" {
    network {
      mode = "bridge"

      port "http" {
        static = 9002
        to     = 9002
      }

      port "envoy" {
        to = 9102
      }
    }

    service {
      name = "count-dashboard"
      port = "http"

      meta {
        dashboard = "F8eFiYKnk"
      }

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "count-api"
              local_bind_port  = 8080
            }
          }
        }
      }
    }

    service {
      name = "envoy"
      port = "envoy"
    }

    task "dashboard" {
      driver = "docker"

      resources {
        memory = 32
      }

      env {
        COUNTING_SERVICE_URL = "http://${NOMAD_UPSTREAM_ADDR_count_api}"
      }

      config {
        image = "hashicorpnomad/counter-dashboard:v3"
      }
    }
  }
}
