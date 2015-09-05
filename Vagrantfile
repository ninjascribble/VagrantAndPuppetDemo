Vagrant.configure("2") do |config|

  config.vm.box = "trusty64"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.network :forwarded_port, guest: 8080, host: 8080    #nginx

  config.vm.synced_folder "", "/vagrant", disabled: true
  config.vm.synced_folder "", "/var/src", owner: "www-data", group: "www-data"

  config.vm.provider :virtualbox do |v|
    v.memory = 1024
    v.cpus = 2
  end

  config.vm.provision :puppet do |puppet|
    puppet.working_directory = "/var/src/provisioning/puppet"
    puppet.hiera_config_path = "provisioning/puppet/hiera.yaml"
    puppet.manifests_path = "provisioning/puppet/manifests"
    puppet.module_path = "provisioning/puppet/modules"
    puppet.manifest_file = "init.pp"
    puppet.options = "--verbose --debug"
    puppet.facter = {
      "public_domain" => "localhost",  # export FACTER_public_domain=localhost
      "environment" => "local" # export FACTER_environment=local
    }
  end
end
