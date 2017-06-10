#
# Author:: Joshua Timberman <joshua@opscode.com>
# Cookbook Name:: couchdb
# Recipe:: source
#
# Copyright 2010, Opscode, Inc
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

if node['platform'] == 'ubuntu' && node['platform_version'].to_f == 8.04
  log "Ubuntu 8.04 does not supply sufficient development libraries via APT to install CouchDB #{node['couch_db']['src_version']} from source."
  return
end

couchdb_tar_gz = File.join(Chef::Config[:file_cache_path], '/', "apache-couchdb-#{node['couch_db']['src_version']}.tar.gz")
compile_flags = ''
dev_pkgs = []
env_vars = {}

case node['platform_family']
when 'debian'

  dev_pkgs << 'libicu-dev'
  dev_pkgs << 'libcurl4-openssl-dev'
  dev_pkgs << value_for_platform(
    'debian' => {
      '< 7.0' => 'libmozjs-dev',
      'default' => 'libmozjs185-dev'
    },
    'ubuntu' => {
      '12.04' => 'libmozjs-dev',
      'default' => 'libmozjs185-dev'
    }
  )

when 'rhel'
  include_recipe 'yum-epel'

  dev_pkgs += %w(
    which make gcc gcc-c++ js-devel libtool
    libicu-devel openssl-devel libcurl-devel libcurl
  )

  env_vars['PKG_CONFIG_PATH'] = '/usr/lib/pkgconfig:/usr/lib64/pkgconfig'

  # awkwardly tell ./configure where to find Erlang's headers
  compile_flags = if Dir.exist?('/usr/lib64')
                    '--with-erlang=/usr/lib64/erlang/usr/include'
                  else
                    '--with-erlang=/usr/lib/erlang/usr/include'
                  end
end

include_recipe 'erlang' if node['couch_db']['install_erlang']

dev_pkgs.each do |pkg|
  package pkg
end

remote_file couchdb_tar_gz do
  checksum node['couch_db']['src_checksum']
  source node['couch_db']['src_mirror']
end

bash "install couchdb #{node['couch_db']['src_version']}" do
  cwd Chef::Config[:file_cache_path]
  environment env_vars
  code <<-EOH
    set -e
    tar -zxf #{couchdb_tar_gz}
    cd apache-couchdb-#{node['couch_db']['src_version']}
    ./configure #{compile_flags}
    make
    make install
    cd ..
    rm -rf #{couchdb_tar_gz} apache-couchdb-#{node['couch_db']['src_version']}
  EOH
  not_if "test -f /usr/local/bin/couchdb && /usr/local/bin/couchdb -V | grep 'Apache CouchDB #{node['couch_db']['src_version']}'"
end

user 'couchdb' do
  home '/usr/local/var/lib/couchdb'
  comment 'CouchDB Administrator'
  manage_home false
  system true
end

%w(var/lib/couchdb var/log/couchdb var/run/couchdb etc/couchdb etc/couchdb/local.d).each do |dir|
  directory "/usr/local/#{dir}" do
    owner 'couchdb'
    group 'couchdb'
    recursive true
    mode '0770'
  end
end

couchdb_config '/usr/local/etc/couchdb'

cookbook_file '/etc/init.d/couchdb' do
  source 'couchdb.init'
  owner 'root'
  group 'root'
  mode '0755'
end

service 'couchdb' do
  supports [:restart, :status]
  action [:enable, :start]
end
