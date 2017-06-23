#
# Author:: Joan Touzet <wohali@apache.org>
# Cookbook Name:: couchdb
# Resource:: couchdb_clouseau
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
This creates and destroys a CouchDB Clouseau (search) node, and is automatically
invoked by the `couchdb_node` resource. There is *no need* to include this resource
directly in your wrapper cookbook.

@action create  Create the CouchDB Clouseau node.
#>
=end

resource_name :couchdb_clouseau

#<> @attribute bind_address The address on which the clouseau service will bind.
property :bind_address, String, default: '127.0.0.1'
#<> @attribute index_dir The directory in which the clouseau service will store its indexes.
property :index_dir, String, default: 'default'
#<> @attribute cookie The Erlang cookie with which the clouseau service will join the cluster.
property :cookie, String, default: 'monster'

action :create do
  # new_resource.name should match the couchdb node name
  # this is used for unambiguous paths and service name
  full_name = "clouseau-#{name}"

  # clouseau gets its own user
  group 'clouseau' do
    system true
  end

  user 'clouseau' do
    comment 'CouchDB clouseau Administrator'
    gid 'clouseau'
    shell '/bin/bash'
    # we can't use /opt because ~/.m2 needs to be writeable
    home '/home/clouseau'
    manage_home true
    system true
    action [:create, :lock]
  end

  # install prerequisites
  log 'javawarning' do
    message 'JDK 6 (not 7/8/9) must be installed prior to couchdb on this platform!'
    level :warn
    only_if do
      (node['platform'] == 'ubuntu' && node['platform_version'].to_f >= 16.00) ||
        (node['platform'] == 'debian' && node['platform_version'].to_f >= 8.00)
    end
  end
  if (node['platform'] == 'ubuntu' && node['platform_version'].to_f < 16.00) ||
     (node['platform'] == 'debian' && node['platform_version'].to_f < 8.00) ||
     (node['platform_family'] == 'rhel')
    include_recipe 'java::default'
  end
  include_recipe 'maven::default'

  # Convenience: if using default node name, use expected paths
  full_install_path = if name == 'couchdb'
                        '/opt/clouseau'
                      else
                        "/opt/#{full_name}"
                      end

  full_index_path = if index_dir != 'default'
                      index_dir
                    elsif name == 'couchdb'
                      '/var/lib/clouseau'
                    else
                      "/var/lib/#{full_name}"
                    end

  [full_install_path, full_index_path].each do |path|
    directory path do
      user 'clouseau'
      group 'clouseau'
      recursive true
      mode '0775'
    end
  end

  git full_install_path do
    repository node['couch_db']['clouseau']['repo_url']
    revision node['couch_db']['clouseau']['repo_tag']
    action :sync
    user 'clouseau'
    group 'clouseau'
  end

  # create clouseau.ini file
  template "#{full_install_path}/clouseau.ini" do
    cookbook 'couchdb'
    source 'clouseau.ini.erb'
    mode '0640'
    owner 'clouseau'
    group 'clouseau'
    variables(
      nodename: full_name,
      cookie: cookie,
      address: bind_address,
      indexdir: full_index_path
    )
  end

  # systemd service for platforms that use it
  systemd_unit "#{full_name}.service" do
    content <<-EOH.gsub(/^\s+/, '')
    [Unit]
    Description=Apache CouchDB clouseau search provider - node #{full_name}
    Wants=couchdb-#{new_resource.name}.service
    After=couchdb-#{new_resource.name}.service

    [Service]
    RuntimeDirectory=#{full_name}
    WorkingDirectory=#{full_install_path}
    User=clouseau
    Group=clouseau
    ExecStart=/opt/maven/bin/mvn scala:run -Dlauncher=clouseau -DaddArgs=#{full_install_path}/clouseau.ini
    Restart=always

    [Install]
    WantedBy=multi-user.target
    EOH
    action [:create, :enable]
    only_if 'systemctl | grep "^\s*-\.mount" >/dev/null'
  end
  service full_name do
    supports status: true, restart: true
    action [:enable, :start]
    subscribes :restart, "template[#{full_install_path}/clouseau.ini]", :delayed
    only_if 'systemctl | grep "^\s*-\.mount" >/dev/null'
  end

  # SysV-init style startup script for other platforms
  template "/etc/init.d/#{full_name}" do
    cookbook 'couchdb'
    source 'clouseau.init.erb'
    mode '0755'
    owner 'clouseau'
    group 'clouseau'
    variables(
      clouseaunodename: full_name,
      clouseaupath: full_install_path
    )
    action :create
    notifies :restart, "service[#{full_name}]", :immediate
    not_if 'systemctl | grep "^\s*-\.mount" >/dev/null'
  end

  # clever not_if here checks if systemd is running on this machine
  service full_name do
    init_command "/etc/init.d/#{full_name}"
    supports status: true, restart: true, reload: false
    action [:enable, :start]
    subscribes :restart, "template[#{full_install_path}/clouseau.ini]", :delayed
    notifies :run, 'bash[finish_standalone_setup]', :immediately
    not_if 'systemctl | grep "^\s*-\.mount" >/dev/null'
  end
end

# TODO: action :delete do
