Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.post_up_message = "Check the README file for next steps"

  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder ".", "/ridepilot"

  config.ssh.forward_agent = true
  
  config.vm.provider :virtualbox do |vb|
    vb.name = "ridepilot-development-trusty"
    vb.customize ["modifyvm", :id, "--memory", "1024"]
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "25"]
  end

  config.vm.provision :shell do |shell|
    # Temporary work around for upgrading RVM until
    # https://github.com/fnichol/chef-rvm/issues/278 is fixed
    shell.inline = "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3"
    shell.privileged = false
  end
  
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "cookbooks"

    chef.add_recipe "locale"
    chef.add_recipe "apt-upgrade-once"
    chef.add_recipe "apt"
    chef.add_recipe "build-essential"
    chef.add_recipe "git"
    chef.add_recipe "vim"
    chef.add_recipe "rvm::vagrant"
    chef.add_recipe "rvm::user"
    chef.add_recipe "postgresql::server"
    chef.add_recipe "postgresql::contrib"
    chef.add_recipe "postgresql::client"
    chef.add_recipe "postgresql::ruby"
    chef.add_recipe "postgis"
    chef.add_recipe "packages"
    chef.add_recipe "imagemagick"
    chef.add_recipe "imagemagick::rmagick"

    chef.json = {
      # Install Ruby 2.1.2 and Bundler
      rvm: {
        vagrant: {
          # Ensure Chef Solo can continue to run after RVM is installed
          system_chef_solo: '/opt/chef/bin/chef-solo'
        },
        user_installs: [{
          user: 'vagrant',
          upgrade: 'stable',
          default_ruby: "ruby-2.1.4",
          rubies: ["ruby-2.1.4", "ruby-1.9.3-p550"],
          global_gems: [{name: 'bundler'}],
          rvmrc: {
            rvm_project_rvmrc: 1,
            rvm_gemset_create_on_use_flag: 1,
            rvm_pretty_print_flag: 1,
            rvm_trust_rvmrcs_flag: 1
          },
        }]
      },
      postgresql: {
        pg_hba: [
          {
            :type => 'local', 
            :db => 'all', 
            :user => 'all', 
            :addr => '', 
            :method => 'trust'
          },
          {
            :type => 'host', 
            :db => 'all', 
            :user => 'all', 
            :addr => '127.0.0.1/32', 
            :method => 'md5'
          },
          {
            :type => 'host', 
            :db => 'all', 
            :user => 'all', 
            :addr => '::1/128', 
            :method => 'md5'
          }
        ],
        config_pgtune: { db_type: 'desktop' },
        contrib: {
          extensions: ["fuzzystrmatch"]
        },
        # https://github.com/opscode-cookbooks/postgresql#chef-solo-note
        # set to md5 of empty string
        password: { postgres: "d41d8cd98f00b204e9800998ecf8427e" }
      },
      postgis: { template_name: 'template_postgis' },
      packages: ["ruby-dev"]
    }
  end
end
