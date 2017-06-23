#
# Author:: Joan Touzet <wohali@apache.org>
# Cookbook Name:: couchdb
# Recipe:: prereq
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
INTERNAL USE ONLY. Creates directories, users, and installs runtime and build
prerequisites for CouchDB when installing from source.
#>
=end

group 'couchdb' do
  system true
end

user 'couchdb' do
  comment 'CouchDB Administrator'
  gid 'couchdb'
  shell '/bin/bash'
  home '/var/lib/couchdb'
  manage_home true
  system true
  action [:create, :lock]
end

# Symlinks to these under /opt/couchdb will be created after installation
%w(/var/lib/couchdb /var/log/couchdb).each do |dir|
  directory dir do
    owner 'couchdb'
    group 'couchdb'
    recursive true
    mode '0775'
  end
end

# install runtime prerequisites
case node['platform_family']
when 'rhel'
  include_recipe 'yum-epel'
  package %w(curl libicu procps python-progressbar python-requests
             chkconfig initscripts)
  # TODO: Fix CentOS 6 support, needs repo with js-1.8.5
  package %w(js js-devel) do
    version ['1.8.5-19.el7', '1.8.5-19.el7']
  end
when 'debian'
  package %w(adduser curl libicu-dev libmozjs185-dev procps python
             python-requests python-progressbar)
  package 'init-system-helpers' do
    only_if do
      (node['platform'] == 'debian' && node['platform_version'].to_f >= 8.0) ||
        (node['platform'] == 'ubuntu' && node['platform_version'].to_f >= 14.00)
    end
  end
  # TODO: Support more than rhel and debian flavoured platforms
end

# install build prerequisites
include_recipe 'build-essential'
include_recipe 'erlang::esl'

# fix bug on Ubuntu 16+ with ESL erlang package
bash 'remove_erlang_manpage_symlink' do
  code <<-EOH
    rm /usr/lib/erlang/man
  EOH
  only_if { node['platform'] == 'ubuntu' && node['platform_version'].to_f >= 16.00 }
end

case node['platform_family']
when 'rhel'
  package %w(git help2man libcurl-devel libicu-devel python)
when 'debian'
  package %w(git help2man libcurl4-openssl-dev libicu-dev libmozjs185-dev
             shunit2 tar)
end

# for couchup, coming in 2.1
include_recipe 'poise-python'
