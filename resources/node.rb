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
This creates a CouchDB node, either standalone or as part of a cluster.

@action create  Create the CouchDB node.

@section Examples

    # Standalone node with full-text search enabled.
    couchdb_node 'couchdb' do
      admin_username 'admin'
      admin_password 'password'
      fulltext true
      type 'standalone'
    end
#>
=end

resource_name :couchdb_node

require 'resolv'
require 'securerandom'

#<> @attribute bind_address The address to which CouchDB will bind.
property :bind_address, String, default: '0.0.0.0'
#<> @attribute port The port to which CouchDB will bind the main interface.
property :port, Integer, default: 5984
#<> @attribute local_port The port to which CouchDB will bind the node-local (backdoor) interface.
property :local_port, Integer, default: 5986
#<> @attribute admin_username The administrator username for CouchDB. In a cluster, all nodes should have the same administrator.
property :admin_username, String, required: true
#<> @attribute admin_password The administrator password for CouchDB. In a cluster, all nodes should have the same administrator.
property :admin_password, String, required: true
#<> @attribute uuid The UUID for the node. In a cluster, all node UUIDs must match. Auto-generated if not specified.
property :uuid, String, default: lazy { ::SecureRandom.uuid.tr('-', '') }
#<> @attribute cookie The cookie for the node. In a cluster, all node cookies must match.
property :cookie, String, default: 'monster'
#<> @attribute type The type of the node - `standalone` or `clustered`.
property :type, String, default: 'clustered'
#<> @attribute loglevel The logging level of the node.
property :loglevel, String, default: 'info'
#<> @attribute config A hash specifying additional settings for the CouchDB configuration ini files. The first level of the hash represents section headings. The second level contains key-pair values to place in the ini file. See `test/cookbooks/couchdb-wrapper-test/recipes/one-node-from-source.rb` for more detail.
property :config, Hash, default: {}
#<> @attribute fulltext Whether to enable full-text search functionality or ont.
property :fulltext, [true, false], default: false
#<> @attribute extra_vm_args Additional Erlang launch arguments to place in the `vm.args` file. Can be used to specify `inet_dist_listen_min`, `inet_dist_listen_max` and `inet_dist_use_interface` options, for example.
property :extra_vm_args, String

action :create do
  node.normal['couch_db']['enable_search'] = true if fulltext

  # install prerequisites, and compile CouchDB
  include_recipe 'couchdb::prereq'
  include_recipe 'couchdb::compile'

  # Convenience: if using default node name, use expected paths
  couchpath = if name == 'couchdb'
                '/opt/couchdb'
              else
                "/opt/couchdb-#{name}"
              end
  datapath = if name == 'couchdb'
               '/var/lib/couchdb'
             else
               "/var/lib/couchdb/#{name}"
             end
  logpath = if name == 'couchdb'
              '/var/log/couchdb'
            else
              "/var/log/couchdb/#{name}"
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
      couchnodename: new_resource.name,
      cookie: cookie,
      address: address,
      extraargs: extra_vm_args
    )
    notifies :restart, "service[couchdb-#{new_resource.name}]", :delayed
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
      clusterport: new_resource.port,
      clusterbindaddress: new_resource.bind_address,
      localport: new_resource.local_port,
      config: new_resource.config
    )
    notifies :restart, "service[couchdb-#{new_resource.name}]", :delayed
  end

  # create local.d ini file
  template "#{couchpath}/etc/local.d/20-dreyfus.ini" do
    cookbook 'couchdb'
    source '20-dreyfus.ini.erb'
    mode '0640'
    owner 'couchdb'
    group 'couchdb'
    variables(
      clouseauname: "clouseau-#{new_resource.name}"
    )
    only_if { fulltext }
    notifies :restart, "service[couchdb-#{new_resource.name}]", :delayed
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
      uuid: new_resource.uuid,
      adminuser: admin_username,
      adminpassword: admin_password
    )
    action :create_if_missing
    notifies :restart, "service[couchdb-#{new_resource.name}]", :delayed
  end

  # systemd service for platforms that use it
  systemd_unit "couchdb-#{new_resource.name}.service" do
    content <<-EOH.gsub(/^\s+/, '')
    [Unit]
    Description=Apache CouchDB - node #{new_resource.name}
    Wants=network-online.target
    After=network-online.target

    [Service]
    RuntimeDirectory=couchdb-#{new_resource.name}
    User=couchdb
    Group=couchdb
    ExecStart=#{couchpath}/bin/couchdb
    Restart=always

    [Install]
    WantedBy=multi-user.target
    EOH
    action [:create, :enable]
    only_if 'systemctl | grep "^\s*-\.mount" >/dev/null'
  end
  service "couchdb-#{new_resource.name}" do
    supports status: true, restart: true
    action [:enable, :start]
    notifies :run, 'bash[finish_standalone_setup]', :immediately
    only_if 'systemctl | grep "^\s*-\.mount" >/dev/null'
  end

  # SysV-init style startup script for other platforms
  template "/etc/init.d/couchdb-#{new_resource.name}" do
    cookbook 'couchdb'
    source 'couchdb.init.rhel.erb'
    mode '0755'
    owner 'couchdb'
    group 'couchdb'
    variables(
      couchpath: couchpath
    )
    action :create
    not_if 'systemctl | grep "^\s*-\.mount" >/dev/null'
    only_if { node['platform_family'] == 'rhel' }
  end
  template "/etc/init.d/couchdb-#{new_resource.name}" do
    cookbook 'couchdb'
    source 'couchdb.init.debian.erb'
    mode '0755'
    owner 'couchdb'
    group 'couchdb'
    variables(
      couchpath: couchpath
    )
    action :create
    not_if 'systemctl | grep "^\s*-\.mount" >/dev/null'
    only_if { node['platform_family'] == 'debian' }
  end

  # clever not_if here checks if systemd is running on this machine
  service "couchdb-#{new_resource.name}" do
    init_command "/etc/init.d/couchdb-#{new_resource.name}"
    supports status: true, restart: true, reload: false
    action [:enable, :start]
    subscribes :restart, "template[/etc/init.d/couchdb-#{new_resource.name}]", :immediately
    notifies :run, 'bash[finish_standalone_setup]', :immediately
    not_if 'systemctl | grep "^\s*-\.mount" >/dev/null'
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
  couchdb_clouseau new_resource.name do
    cookie new_resource.cookie
    only_if { fulltext }
  end

  # make this node searchable for clustering
  ruby_block 'register_node' do
    block do
      Chef::Log.info(new_resource.name)
      node.default['couch_db']['nodes'][new_resource.name]['address'] = address
      node.default['couch_db']['nodes'][new_resource.name]['port'] = port
      # this allows us to converge a dev system in a single run
      node.save unless Chef::Config[:solo] # ~FC075
    end
    not_if { type == 'standalone' }
  end
end

# TODO: action :delete do
