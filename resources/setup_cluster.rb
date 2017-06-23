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

Through the use of the `address` and `port` options, this resource can be
run on any Chef-managed machine. It does not have to run on a CouchDB node.

Operators can also avoid this role and manage cluster membership and
finalisation outside of Chef.
#>
=end
resource_name :couchdb_setup_cluster

#<> @attribute address The CouchDB address through which cluster management is performed.
property :address, String, default: '127.0.0.1'
#<> @attribute port The port for the CouchDB address through which cluster management is performed.
property :port, Integer, default: 5984
#<> @attribute admin_username The administrator username for CouchDB. In a cluster, all nodes should have the same administrator.
property :admin_username, String, required: true
#<> @attribute admin_password The administrator password for CouchDB. In a cluster, all nodes should have the same administrator.
property :admin_password, String, required: true
#<> @attribute role The role to which all nodes in the cluster should belong. Used with Chef Search to retrieve a current list of node addresses and ports.
property :role, String, default: 'couchdb'
#<> @attribute search_string Override of the default `roles:<role>` Chef Search expression. Modify this if you need to build a list of nodes in the cluster via different search terms.
property :search_string, String, default: 'default'
#<> @attribute num_nodes Required. Number of nodes the Chef Search should return. Ensures that all nodes have been provisioned prior to joining them into a cluster.
property :num_nodes, Integer, required: true
#<> @attribute node_list Optional array of [address, port] pairs representing all nodes in the cluster. If a static list is specified here, it will override the Chef Search. Only these nodes will be joined into the cluster. Only use this as a last resort. Example: `[['127.0.0.1', 15984], ['127.0.0.1', 25984], ['127.0.0.1', 35984]]`.
property :node_list, Array, default: []

default_action :create

action :create do
  # httparty gem to simplify setup magic
  chef_gem 'httparty' do
    # as per https://www.chef.io/blog/2015/02/17/chef-12-1-0-chef_gem-resource-warnings/
    compile_time false if Chef::Resource::ChefGem.method_defined?(:compile_time)
    action :install
    compile_time false
  end

  doit = true
  options = { basic_auth: { username: new_resource.admin_username, password: new_resource.admin_password } }

  ruby_block 'look_for_users_db' do # ~FC005
    block do
      require 'httparty'
      # Check if we need to do anything
      class Couch
        include HTTParty
        debug_output
      end
      begin
        response = Couch.get("http://#{new_resource.address}:#{new_resource.port}/_users", options)
        doit = (response.code != 200)
      rescue
        # couch is not running, cannot proceed!
        doit = false
      end
    end
  end

  nodes = []

  # search for nodes, if necessary
  ruby_block 'search_for_nodes' do # ~FC014
    block do
      if node_list.empty?
        srch = if search_string == 'default'
                 "roles:#{role}"
               else
                 search_string
               end
        Chef::Log.warn(srch)
        search_results = search(:node, srch)
        Chef::Log.warn(search_results)
        search_results.each do |n|
          n['couch_db']['nodes'].each_value do |nn|
            nodes << [nn['address'], nn['port']]
          end
        end
      else
        nodes = node_list
      end
      if nodes.length != num_nodes
        Chef::Log.warn("Refusing to finalise cluster. #{num_nodes} expected, #{nodes.length} found.")
        doit = false
      end
    end
    only_if { doit }
  end

  # check everyone is /_up
  ruby_block 'check_nodes_are_up' do
    block do
      nodes.each do |n|
        begin
          response = Couch.get("http://#{n[0]}:#{n[1]}/_up", options)
          if response.code != 200
            doit = false
            break
          end
        rescue
          doit = false
          break
        end
      end
    end
    only_if { doit }
  end

  # PUT each node
  ruby_block 'add_all_the_nodes' do
    block do
      options[:headers] = { 'Content-Type' => 'application/json' }
      nodes.each do |n|
        begin
          unless n[0] == new_resource.address && n[1] == new_resource.port
            options[:body] = %({"action":"add_node","host":"#{n[0]}","port":"#{n[1]}","username":"#{new_resource.admin_username}","password":"#{new_resource.admin_password}"})
            response = Couch.post("http://#{new_resource.address}:#{new_resource.port}/_cluster_setup", options)
            unless [201, 409].include? response.code
              Chef::Log.warn("Failed to add node #{n[0]}:#{n[1]}: #{response.body}")
              doit = false
              break
            end
          end
        rescue
          doit = false
          break
        end
      end
    end
    only_if { doit }
  end

  # Finalise the cluster
  ruby_block 'finalise_cluster' do
    block do
      options[:body] = '{"action":"finish_cluster"}'
      begin
        response = Couch.post("http://#{new_resource.address}:#{new_resource.port}/_cluster_setup", options)
        if response.code != 201
          Chef::Log.warn("Failed to finalise cluster: #{response.body}")
          doit = false
        end
      rescue
        Chef::Log.warn("Failed to finalise cluster: #{response.body}")
        doit = false
      end
    end
    only_if { doit }
  end
end
