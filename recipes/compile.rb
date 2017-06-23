#
# Author:: Joan Touzet <wohali@apache.org>
# Cookbook Name:: couchdb
# Recipe:: compile
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
INTERNAL USE ONLY. Downloads and compiles CouchDB from source.
#>
=end

couchdb_tar_gz = "/usr/src/archives/apache-couchdb-#{node['couch_db']['src_version']}.tar.gz"
node.default['couch_db']['extract_path'] = "/usr/src/apache-couchdb-#{node['couch_db']['src_version']}"
env_vars = {}

case node['platform_family']
when 'rhel'
  env_vars['PKG_CONFIG_PATH'] = '/usr/lib/pkgconfig:/usr/lib64/pkgconfig'
end

directory '/usr/src/archives' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# search requires a diff to be applied to the source code
template "/usr/src/search-diff-#{node['couch_db']['src_version']}.patch" do
  cookbook 'couchdb'
  source "search-diff-#{node['couch_db']['src_version']}.patch.erb"
  mode '0640'
  owner 'couchdb'
  group 'couchdb'
  variables(
    dreyfus_repo_url: node['couch_db']['dreyfus']['repo_url'],
    dreyfus_repo_tag: node['couch_db']['dreyfus']['repo_tag']
  )
  only_if { node['couch_db']['enable_search'] }
end

remote_file couchdb_tar_gz do
  source node['couch_db']['src_mirror']
  checksum node['couch_db']['src_checksum']
  notifies :run, 'bash[extract_tarball]', :immediately
end

bash 'extract_tarball' do
  cwd '/usr/src'
  code <<-EOH
    set -e
    rm -rf #{node['couch_db']['extract_path']}
    tar -zxf #{couchdb_tar_gz}
  EOH
  action :nothing
  notifies :run, 'bash[patch_for_search]', :immediately
end

bash 'patch_for_search' do
  cwd node['couch_db']['extract_path']
  code <<-EOH
    set -e
    if #{node['couch_db']['enable_search']}; then
      patch -p1 </usr/src/search-diff-#{node['couch_db']['src_version']}.patch
      bin/rebar get-deps
    fi
  EOH
  action :nothing
  notifies :run, 'bash[compile_couchdb]', :immediately
end

bash 'compile_couchdb' do
  cwd node['couch_db']['extract_path']
  code <<-EOH
    set -e
    ./configure #{node['couch_db']['configure_flags']}
    make release
    # Remove to-be eclipsed paths
    mkdir rel/couchdb/etc/local.d rel/couchdb/etc/default.d || true
    rm -rf rel/couchdb/data rel/couchdb/var/log
  EOH
  action :nothing
  notifies :run, 'bash[install_couchdb]', :immediately
end
