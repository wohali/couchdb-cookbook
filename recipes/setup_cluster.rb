#
# Author:: Joan Touzet <wohali@apache.org>
# Cookbook Name:: couchdb
# Recipe:: setup_cluster
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
Optional role to join all nodes in the cluster together.

NOTE: Intended to be run on a SINGLE NODE IN THE CLUSTER. Adding this to
the run list of more than one node in the cluster will result in undefined,
probably WRONG behaviour.
#>
=end

# Install httparty gem for usage within Chef runs
chef_gem 'httparty' do
  # as per https://www.chef.io/blog/2015/02/17/chef-12-1-0-chef_gem-resource-warnings/
  compile_time false if Chef::Resource::ChefGem.method_defined?(:compile_time)
  action :install
  compile_time false
end
