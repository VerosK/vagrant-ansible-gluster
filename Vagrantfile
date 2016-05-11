# -*- mode: ruby -*-
# vi: set ft=ruby :
# See: https://docs.vagrantup.com/v2/vagrantfile/tips.html



VAGRANTFILE_API_VERSION = "2"

VIRTUAL_MACHINES = {
  :left => {
    :ip             => '192.168.9.31',
  },
  :right => {
    :ip             => '192.168.9.32',
  }
}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.hostmanager.enabled = true
  config.vm.box = "vStone/centos-7.x-puppet.3.x"
  config.ssh.insert_key = false

  VIRTUAL_MACHINES.each do |name,cfg|

    config.vm.define name do |vm_config|
      vm_config.vm.hostname = name
      vm_config.vm.network :private_network, ip: VIRTUAL_MACHINES[name][:ip]

      config.vm.provider :virtualbox do |vb|

        vb.memory = 1024
        vb.cpus = 2
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--ioapic", "on"]

      end # provider

      config.vm.provision :ansible do |ansible|
            ansible.playbook = "site.yml"
            ansible.host_key_checking = false
            ansible.sudo_user = 'root'
            ansible.sudo = true
            ansible.verbose = "v"
            #ansible.tags = 'setup'
            #ansible.tags = 'bricks'
            #ansible.tags = 'mount'
            ansible.groups = {
              'gluster-servers' => [:left, :right],
              'gluster-clients' => [:left, :right],
              'centos'  => VIRTUAL_MACHINES.keys,
              'all:vars' => {
                    'gluster_servers' => [:left, :right]
              }
            }
            # if you want to fire ansible on all machines at parallel, use this!
            ansible.limit = 'all'
      end
    end
  end
end

