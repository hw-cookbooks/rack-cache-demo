# Simulate an external cookbook that sets up a database
include_recipe "postgresql::server"
include_recipe "database::postgresql"

# This could be a search
postgresql_connection_info = {
  :host => node['rack-cache-demo']['database']['hostname'],
  :port => 5432,
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

postgresql_database node['rack-cache-demo']['database']['name'] do
  connection postgresql_connection_info
  action :create
end

postgresql_database node['rack-cache-demo']['database']['name'] do
  connection postgresql_connection_info
  template 'DEFAULT'
  encoding 'DEFAULT'
  tablespace 'DEFAULT'
  connection_limit '-1'
  owner 'postgres'
  action :create
end

Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
node.set_unless['rack-cache-demo']['database']['password'] = secure_password

postgresql_database_user node['rack-cache-demo']['database']['user'] do
  connection postgresql_connection_info
  password node['rack-cache-demo']['database']['password']
  database_name node['rack-cache-demo']['database']['name']
  host node['rack-cache-demo']['database']['host']
  action [:create, :grant]
end
