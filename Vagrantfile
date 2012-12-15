require 'berkshelf/vagrant'

chef_server_url = ENV["CHEF_SERVER_URL"] || "https://api.opscode.com/organizations/aj-org" 
current_dir = File.dirname(__FILE__)
chef_dir = File.join(current_dir, ".chef")

Vagrant::Config.run do |config|
  config.vm.host_name = "rack-cache-demo-berkshelf"

  config.vm.box = "opscode-ubuntu-12.04"

  config.vm.network :hostonly, "33.33.33.10"
  config.ssh.max_tries = 40
  config.ssh.timeout   = 120

  config.vm.forward_port 80, 8080

  config.vm.provision :chef_client do |chef|
    chef.validation_client_name = "aj-org-validator"
    chef.validation_key_path = "#{chef_dir}/validator.pem"
    chef.chef_server_url = chef_server_url
    chef.run_list = [
                     "role[database_master]",
                     "role[memcached_master]",
                     "role[application]"
                    ]
  end
end
