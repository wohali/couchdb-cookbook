#
# Author:: Joan Touzet <wohali@apache.org>
# Cookbook Name:: couchdb
# Resource:: couchdb_node
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
=begin
#<
This creates and destroys a CouchDB node.

@action create  Create the CouchDB node.
@action destroy Destroy the CouchDB node.

@section Examples

    # An example of my awesome service
    mycookbook_awesome_service "my_service" do
      port 80
    end
#>
=end

resource_name :couchdb_node

require 'resolv'
require 'securerandom'

property :node_name, String, default: 'couchdb'
property :bind_address, String, default: '0.0.0.0'
property :port, Integer, default: 5984
property :local_port, Integer, default: 5986
property :admin_username, String, required: true
property :admin_password, String, required: true
property :uuid, String, default: lazy { ::SecureRandom.uuid.tr('-', '') }
property :cookie, String, default: 'monster'
property :type, String, default: 'clustered'
property :loglevel, String, default: 'info'
property :fulltext, [true, false], default: false

action :create do
  node.default['couch_db']['enable_search'] = true if fulltext

  # install prerequisites, and compile CouchDB
  include_recipe 'couchdb::prereq'
  include_recipe 'couchdb::compile'

  # Convenience: if using default node name, use expected paths
  couchpath = if node_name == 'couchdb'
                '/opt/couchdb'
              else
                "/opt/couchdb-#{node_name}"
              end
  datapath = if node_name == 'couchdb'
               '/var/lib/couchdb'
             else
               "/var/lib/couchdb/#{node_name}"
             end
  logpath = if node_name == 'couchdb'
              '/var/log/couchdb'
            else
              "/var/log/couchdb/#{node_name}"
            end

  bash 'install_couchdb' do
    code <<-EOH
      cp -R #{node['couch_db']['extract_path']}/rel/couchdb #{couchpath}
    EOH
    not_if { ::File.directory?(couchpath) }
  end

  # create directories for node-specific config, data, logs
  [datapath, logpath].each do |path|
    directory path do
      owner 'couchdb'
      group 'couchdb'
      recursive true
      mode '0775'
    end
  end

  # setup symlinks to var and log paths
  link "#{couchpath}/data" do
    to datapath
  end
  link "#{couchpath}/var/log" do
    to logpath
  end

  # Determine the address of the node for the name
  if type == 'standalone'
    address = 'localhost'
    frontip = '127.0.0.1'
  elsif type == 'clustered' && bind_address == '127.0.0.1'
    Chef::Application.fatal!('Clustered CouchDB nodes cannot be bound to 127.0.0.1!', 1)
  elsif type == 'clustered' && bind_address == '0.0.0.0'
    begin
      frontip = '127.0.0.1'
      address = if Resolv.getaddress(node['fqdn']) == node['ipaddress']
                  node['fqdn']
                else
                  # ¯\_(ツ)_/¯
                  node['ipaddress']
                end
    rescue
      address = node['ipaddress']
    end
  else
    address = bind_address
    frontip = bind_address
  end

  # create vm.args file
  template "#{couchpath}/etc/vm.args" do
    cookbook 'couchdb'
    source 'vm.args.erb'
    mode '0640'
    owner 'couchdb'
    group 'couchdb'
    variables(
      couchnodename: node_name,
      cookie: cookie,
      address: address
    )
    notifies :restart, "service[couchdb-#{node_name}]", :delayed
  end

  # create local.d ini file
  template "#{couchpath}/etc/local.d/10-chef-config.ini" do
    cookbook 'couchdb'
    source '10-chef-config.ini.erb'
    mode '0640'
    owner 'couchdb'
    group 'couchdb'
    variables(
      logpath: logpath,
      loglevel: loglevel,
      datapath: datapath,
      clusterport: port,
      clusterbindaddress: bind_address,
      localport: local_port
    )
    notifies :restart, "service[couchdb-#{node_name}]", :delayed
  end

  # create local.d ini file
  template "#{couchpath}/etc/local.d/20-dreyfus.ini" do
    cookbook 'couchdb'
    source '20-dreyfus.ini.erb'
    mode '0640'
    owner 'couchdb'
    group 'couchdb'
    variables(
      clouseauname: "clouseau-#{node_name}"
    )
    only_if { fulltext }
    notifies :restart, "service[couchdb-#{node_name}]", :delayed
  end

  # create_if_missing specified to avoid fighting over a hashed admin password
  # or other local changes. It means we can't keep this file updated.
  # uuid is in here as well, to simplify setup for single-node deployments
  template "#{couchpath}/etc/local.d/50-admins.ini" do
    cookbook 'couchdb'
    source '50-admins.ini.erb'
    mode '0640'
    owner 'couchdb'
    group 'couchdb'
    variables(
      uuid: uuid,
      adminuser: admin_username,
      adminpassword: admin_password
    )
    action :create_if_missing
    notifies :restart, "service[couchdb-#{node_name}]", :delayed
  end

  # TODO: Bring back couch_config template/provider here

  # systemd service for platforms that use it
  systemd_unit "couchdb-#{node_name}.service" do
    content <<-EOH.gsub(/^\s+/, '')
    [Unit]
    Description=Apache CouchDB - node #{node_name}
    Wants=network-online.target
    After=network-online.target

    [Service]
    RuntimeDirectory=couchdb-#{node_name}
    User=couchdb
    Group=couchdb
    ExecStart=#{couchpath}/bin/couchdb
    Restart=always

    [Install]
    WantedBy=multi-user.target
    EOH
    action [:create, :enable]
    only_if '[[ $(systemctl) =~ -\.mount ]]'
  end
  service "couchdb-#{node_name}" do
    supports status: true, restart: true
    action [:enable, :start]
    notifies :run, 'bash[finish_standalone_setup]', :immediately
    only_if '[[ $(systemctl) =~ -\.mount ]]'
  end

  # SysV-init style startup script for other platforms
  # systemd will ignore an /etc/init.d script, so always install it
  template "/etc/init.d/couchdb-#{node_name}" do
    cookbook 'couchdb'
    source 'couchdb.init.rhel.erb'
    mode '0640'
    owner 'couchdb'
    group 'couchdb'
    variables(
      couchpath: couchpath
    )
    action :create
    not_if '[[ $(systemctl) =~ -\.mount ]]'
    only_if { node['platform_family'] == 'rhel' }
  end
  template "/etc/init.d/couchdb-#{node_name}" do
    cookbook 'couchdb'
    source 'couchdb.init.debian.erb'
    mode '0640'
    owner 'couchdb'
    group 'couchdb'
    variables(
      couchpath: couchpath
    )
    action :create
    not_if '[[ $(systemctl) =~ -\.mount ]]'
    only_if { node['platform_family'] == 'debian' }
  end

  # clever not_if here checks if systemd is running on this machine
  service "couchdb-#{node_name}" do
    init_command "/etc/init.d/couchdb-#{node_name}"
    supports status: true, restart: true, reload: false
    action [:enable, :start]
    notifies :run, 'bash[finish_standalone_setup]', :immediately
    not_if '[[ $(systemctl) =~ -\.mount ]]'
  end

  # standalone setup can be completed once service is running
  # the sleep is to prevent this from running before couch is fully up
  bash 'finish_standalone_setup' do
    code <<-EOH
      sleep 5
      curl -X PUT --user #{admin_username}:#{admin_password} http://#{frontip}:#{port}/_users || true
      curl -X PUT --user #{admin_username}:#{admin_password} http://#{frontip}:#{port}/_replicator || true
      curl -X PUT --user #{admin_username}:#{admin_password} http://#{frontip}:#{port}/_global_changes || true
    EOH
    action :nothing
    only_if { type == 'standalone' }
    not_if "curl http://#{frontip}:#{port}/_users"
  end

  # now that CouchDB is running, maybe create & start clouseau if requested
  couchdb_clouseau "clouseau-#{node_name}" do
    couch_node_name node_name
    clouseau_node_name "clouseau-#{node_name}"
    cookie new_resource.cookie
    only_if { fulltext }
  end
end

# TODO: action :delete do
