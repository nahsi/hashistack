# vim: set ft=ruby:
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.define "hashistack"
  config.vm.hostname = "hashistack"
  config.vm.synced_folder ".", "/vagrant", type: "rsync"
  config.vm.provider :virtualbox do |vb|
      vb.name = "hashistack"
      # disable log file
      vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
  end

  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "playbooks/bootstrap.yml"
  end

  ports = [
    8500, # consul
    4646, # nomad
    8200, # vault
    9090, # prometheus
    3000, # grafana
    9002  # countdash-dashboard
  ]
  ports.each do |port|
    config.vm.network "forwarded_port", guest: port, host: port, host_ip: "127.0.0.1"
  end

  jobs = [
    "prometheus",
    "loki",
    "tempo",
    "grafana",
    "countdash"
  ]
  jobs.each do |job|
    config.vm.provision "shell",
      inline:<<EOH
tries=5
until [[ $(curl -sS http://localhost:4646/v1/operator/autopilot/health | jq .Healthy) == true ]]
do
  if [[ $tries == 0 ]]; then
    echo "Nomad is not healthy"
    exit 1
  fi
  sleep 5
  ((tries--))
done
cd /vagrant/jobs/#{job}
nomad run -detach job.nomad.hcl
EOH
  end
end
