Vagrant::Config.run do |config|
  config.vm.box = "precise64_ruby2"
  config.vm.box_url = "http://vagrant.cloudspace.com.s3.amazonaws.com/cloudspace_ubuntu_12.042_ruby_2.box"

  config.vm.share_folder "rss.cloudspace.com", "/srv/rss.cloudspace.com", "./", :nfs => true
  config.vm.customize ["modifyvm", :id, "--memory", "2048", "--name", "rss.cloudspace.com-dev","--cpus", "2"]
  # config.vm.boot_mode = :gui
  config.vm.network :hostonly, '33.33.33.107'
  config.ssh.private_key_path = File.join(ENV['HOME'], '.ssh', 'cs_vagrant.pem')

  config.vm.provision :chef_solo do |chef|        
    chef.cookbooks_path = "./cookbooks"
    
    chef.add_recipe "ubuntu"
    chef.add_recipe "git"
    chef.add_recipe "postgresql::client"
    chef.add_recipe "postgresql::server"
    
    chef.json = {
      postgresql: {
        password: {
          postgres: 'postgres'
        }
      }      
    }
  end
end
