# HashiStack

HashiCorp stack (Consul+Nomad+vault) in VM.

## Requirements
Vagrant and VirtualBox

## How to use

### Setup

```
vagrant up
```
### Recreate after config update

```
vagrant reload
```

### Destroy

```
vagrant destroy
```

### Run nomad jobs
```
cd jobs/<job>
nomad run job.nomad.hcl
```

## Addresses

| service | address |
| ------- | ------- |
| consul  | http://localhost:8500 |
| nomad  | http://localhost:4646 |
| vault  | http://localhost:8200 |
| grafana  | http://localhost:3000 |
| prometheus  | http://localhost:9090 |
| count-dashboard  | http://localhost:9002 |
