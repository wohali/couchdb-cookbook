#
# Cookbook:: couchdb-wrapper-test
# Recipe:: one-node-from-source
#
# Copyright:: 2017, Joan Touzet <wohali@apache.org>
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

# NOTE: This is test config data. These are NOT recommended defaults!
config_data = {
  couchdb: {
    max_document_size: 2097152,
    max_dbs_open: 1000,
  },
  log: {
    level: 'debug',
  },
}

couchdb_node 'couchdb' do
  admin_username 'admin'
  admin_password 'password'
  type 'standalone'
  config config_data
  # NOTE: These are extra testvm.args arguments, NOT recommended defaults!
  extra_vm_args "-kernel inet_dist_listen_min 9000 inet_dist_listen_max 9100 inet_dist_use_interface '{127,0,0,1}'"
end
