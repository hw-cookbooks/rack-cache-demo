#
# Cookbook:: memcached
# Recipe:: default
#
# Copyright:: (C) 2012 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'ubuntu'
include_recipe 'apt'
include_recipe 'passenger_apache2'
include_recipe 'git'

{ gem_package: 'passenger',
  execute: 'passenger_module' }.each do |resource_type, resource_name|
  r = resources(resource_type => resource_name)
  r.action :nothing
end

apt_repository 'ruby-ng' do
  uri 'ppa:brightbox/ruby-ng'
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key 'C3173AA6'
end

package 'ruby'
package 'rubygems'
package 'ruby1.9.3'
package 'ruby-switch'
package 'passenger-common1.9.1'

execute 'ruby-switch --set ruby1.9.1' do
  action :nothing
  subscribes :run, 'package[ruby-switch]', :immediately
end

ohai 'ruby' do
  plugin 'languages'
  action :nothing
  subscribes :reload, 'package[ruby-switch]', :immediately
end

# Just in case?
gem_package 'bundler' do
  gem_binary '/usr/bin/gem1.9.1'
end

database = node['rack-cache-demo']['database']
database_name = database['name']
database_user = database['user']
database_password = database['password']

application 'rack-cache-demo' do
  path '/srv/rack-cache-demo'
  repository 'git://github.com/fujin/rack-cache-demo.git'
  revision 'master'

  # Passenger expects a tmp directory
  create_dirs_before_symlink %w(tmp)

  rails do
    bundler true
    bundler_deployment true
    precompile_assets true
    database_master_role 'database_master'
    database do
      adapter database_adapter
      database database_name
      username database_user
      password database_password
    end
  end

  memcached do
    role 'memcached_master'
    options do
      ttl 1800
      memory 256
    end
  end

  passenger_apache2 do
  end
end
