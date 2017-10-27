# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

public_key = nil
[ENV['REMORA_PUBLIC_KEY'], "~/.ssh/id_rsa.pub", "~/.ssh/id_dsa.pub"].each do |p_key|
  if p_key
    p_key = File.expand_path(p_key)
    if File.file?(p_key)
      public_key = open(p_key).read
      break
    end
  end
end

unless public_key
  raise "Please specify ssh public key using following env: REMORA_PUBLIC_KEY"
end

SCRIPT = <<-EOF
echo "#{public_key}" >> ~vagrant/.ssh/authorized_keys
swapoff /dev/sda2
sed -i -e "/swap/d" /etc/fstab
EOF

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "envimation/ubuntu-xenial-docker"
  config.vm.box_url = "https://atlas.hashicorp.com/envimation/boxes/ubuntu-xenial-docker"

  config.vm.define :master do |master|
    master.vm.hostname = "master"
    master.vm.provider "virtualbox" do |v, override|
      v.customize ["modifyvm", :id, "--memory", "2048"]
    end

    master.vm.network :private_network, ip: "192.168.43.101"

    master.vm.provision :shell, inline: SCRIPT
  end

  [[:worker01, 102], [:worker02, 103]].each do |worker|
    config.vm.define worker[0] do |w|
      w.vm.hostname = worker[0].to_s
      w.vm.provider "virtualbox" do |v, override|
        v.customize ["modifyvm", :id, "--memory", "2048"]
      end

      w.vm.network :private_network, ip: "192.168.43.#{worker[1]}"

      w.vm.provision :shell, inline: SCRIPT
    end
  end

end
