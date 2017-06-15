#
# Author:: Joan Touzet <wohali@apache.org>
# Cookbook Name:: couchdb
# Attributes:: couchdb
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# CouchDB source links
default['couch_db']['src_checksum']   = 'ccaf3ce9cb06c50a73e091696e557e2a57c5ba02c5b299e1ac2f5b959ee96eca'
default['couch_db']['src_version']    = '2.0.0'
default['couch_db']['src_mirror']     = "https://archive.apache.org/dist/couchdb/source/#{node['couch_db']['src_version']}/apache-couchdb-#{node['couch_db']['src_version']}.tar.gz"

# Erlang default overrides
default['couch_db']['install_erlang'] = true
node.default['erlang']['install_method'] = 'esl'
node.default['erlang']['esl']['version'] = '18.3-1'

# NodeJS default overrides
node.default['nodejs']['install_method'] = 'binary'

# CouchDB configure and compile options
default['couch_db']['configure_flags'] = '-c'

# Full-text search: dreyfus/clouseau links
default['couch_db']['dreyfus']['repo_url'] = 'https://github.com/cloudant-labs/dreyfus'
default['couch_db']['dreyfus']['repo_tag'] = 'd83888154be546b2826b3346a987089a64728ee5'
default['couch_db']['clouseau']['repo_url'] = 'https://github.com/cloudant-labs/clouseau'
default['couch_db']['clouseau']['repo_tag'] = '32b2294d40c5e738b52b3d57d2fb006456bc18cd'
