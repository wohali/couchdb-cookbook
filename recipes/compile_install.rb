#
# Author:: Joan Touzet <wohali@apache.org>
# Cookbook Name:: couchdb
# Recipe:: compile_install
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
Downloads, compiles and installs CouchDB from source.
#>
=end

couchdb_tar_gz = File.join(Chef::Config[:file_cache_path], "apache-couchdb-#{node['couch_db']['src_version']}.tar.gz")
extract_path = File.join(Chef::Config[:file_cache_path], "apache-couchdb-#{node['couch_db']['src_version']}")
env_vars = {}

case node['platform_family']
when 'rhel'
  env_vars['PKG_CONFIG_PATH'] = '/usr/lib/pkgconfig:/usr/lib64/pkgconfig'
end

remote_file couchdb_tar_gz do
  checksum node['couch_db']['src_checksum']
  source node['couch_db']['src_mirror']
  notifies :run, 'bash[extract_tarball]', :immediately
end

bash 'extract_tarball' do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    set -e
    rm -rf #{extract_path}
    tar -zxf #{couchdb_tar_gz}
  EOH
  action :nothing
  notifies :run, 'bash[compile_couchdb]', :immediately
end

bash 'compile_couchdb' do
  cwd extract_path
  code <<-EOH
    set -e
    ./configure #{node['couch_db']['configure_flags']}
    make release
    # Remove to-be eclipsed paths
    rm -rf rel/couchdb/data rel/couchdb/var/log
  EOH
  action :nothing
  notifies :run, 'bash[install_couchdb]', :immediately
end

bash 'install_couchdb' do
  code <<-EOH
    cp -R #{extract_path}/rel/couchdb /opt
    # cleanup after ourselves
    rm -rf #{extract_path}
  EOH
  action :nothing
end

# setup symlinks to well-recognized places
link '/opt/couchdb/data' do
  to '/var/lib/couchdb'
end

link '/opt/couchdb/var/log' do
  to '/var/log/couchdb'
end
