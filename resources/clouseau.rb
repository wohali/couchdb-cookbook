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
This creates and destroys a CouchDB Clouseau (search) node.

@action create  Create the CouchDB Clouseau node.
@action destroy Destroy the CouchDB Clouseau node.

@section Examples

    # An example of my awesome service
    mycookbook_awesome_service "my_service" do
      port 80
    end
#>
=end

resource_name :couchdb_clouseau

property :couch_node_name, String, default: 'couchdb'
property :clouseau_node_name, String, default: 'clouseau'
property :bind_address, String, default: '127.0.0.1'
property :cookie, String, default: 'monster'

action :create do
  # clouseau gets its own user
  group 'clouseau' do
    system true
  end

  user 'clouseau' do
    comment 'CouchDB clouseau Administrator'
    gid 'clouseau'
    shell '/bin/bash'
    home '/home/clouseau'
    manage_home true
    system true
    action [:create, :lock]
  end

  # install prerequisites
  include_recipe 'java::default'
  include_recipe 'maven::default'

  # Convenience: if using default node name, use expected paths
  clouseaupath = if clouseau_node_name == 'clouseau-couchdb'
                   '/opt/clouseau'
                 else
                   "/opt/#{clouseau_node_name}"
                 end

  directory clouseaupath do
    user 'clouseau'
    group 'clouseau'
  end

  git clouseaupath do
    repository node['couch_db']['clouseau']['repo_url']
    revision node['couch_db']['clouseau']['repo_tag']
    action :sync
    user 'clouseau'
    group 'clouseau'
  end

  # create clouseau.ini file
  template "#{clouseaupath}/clouseau.ini" do
    cookbook 'couchdb'
    source 'clouseau.ini.erb'
    mode '0640'
    owner 'clouseau'
    group 'clouseau'
    variables(
      nodename: clouseau_node_name,
      cookie: cookie,
      address: bind_address
    )
  end

  # systemd service for platforms that use it
  systemd_unit "#{clouseau_node_name}.service" do
    content <<-EOH.gsub(/^\s+/, '')
    [Unit]
    Description=Apache CouchDB clouseau search provider - node #{clouseau_node_name}
    Wants=couchdb-#{couch_node_name}.service
    After=couchdb-#{couch_node_name}.service

    [Service]
    RuntimeDirectory=#{clouseau_node_name}
    WorkingDirectory=#{clouseaupath}
    User=clouseau
    Group=clouseau
    ExecStart=/opt/maven/bin/mvn scala:run -Dlauncher=clouseau -DaddArgs=#{clouseaupath}/clouseau.ini
    Restart=always

    [Install]
    WantedBy=multi-user.target
    EOH
    action [:create, :enable]
    only_if '[[ $(systemctl) =~ -\.mount ]]'
  end
  service clouseau_node_name do
    supports status: true, restart: true
    action [:enable, :start]
    subscribes :restart, "template[#{clouseaupath}/clouseau.ini]", :delayed
    only_if '[[ $(systemctl) =~ -\.mount ]]'
  end

  # TODO: SysV-init style startup script for other platforms
end

# TODO: action :delete do
