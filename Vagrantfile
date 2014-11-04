$domain_name = "rss.cloudspace.dev"
$vagrant_ip = "33.33.164.176"
$box_name = "ruby-postgresql.box"
$box_path = "http://devops.cloudspace.com/images/ruby-postgresql/"
$cpus = 2
$memory = 2048

Vagrant.configure(2) do |config|
  org = $domain_name
  config.vm.box = $box_name
  config.vm.box_url = File.join($box_path, $box_name)
  config.ssh.private_key_path = File.join(ENV['HOME'], '.ssh', 'id_rsa')
  config.ssh.forward_agent = true
  config.vm.network "private_network", ip: $vagrant_ip
  config.vm.synced_folder "./", "/srv/#{org}", :nfs => { :mount_options => ["dmode=777","fmode=777"] }

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", $memory, "--name", $domain_name,"--cpus", $cpus]
    # v.gui = true
  end
end
