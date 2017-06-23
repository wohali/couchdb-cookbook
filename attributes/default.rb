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

#<> Apache CouchDB version to download.
default['couch_db']['src_version']    = '2.0.0'
#<> Apache CouchDB download link.
default['couch_db']['src_mirror']     = "https://archive.apache.org/dist/couchdb/source/#{node['couch_db']['src_version']}/apache-couchdb-#{node['couch_db']['src_version']}.tar.gz"
#<> sha256 checksum of Apache CouchDB tarball.
default['couch_db']['src_checksum']   = 'ccaf3ce9cb06c50a73e091696e557e2a57c5ba02c5b299e1ac2f5b959ee96eca'

#<> Whether CouchDB installation will install Erlang or not.
default['couch_db']['install_erlang'] = true
#<> Method of Erlang installation - `esl` is recommended.
node.default['erlang']['install_method'] = 'esl'
#<> Version of `esl` package to install.
node.default['erlang']['esl']['version'] = if node['platform_family'] == 'rhel'
                                             '18.3-1'
                                           elsif node['platform_family'] == 'debian'
                                             '1:18.3'
                                           end

#<> CouchDB configure options.
default['couch_db']['configure_flags'] = '-c'

#<> Full-text search: dreyfus repository URL
default['couch_db']['dreyfus']['repo_url'] = 'https://github.com/cloudant-labs/dreyfus'
#<> Full-text search: dreyfus repository tag or hash
default['couch_db']['dreyfus']['repo_tag'] = 'd83888154be546b2826b3346a987089a64728ee5'
#<> Full-text search: clouseau repository URL
default['couch_db']['clouseau']['repo_url'] = 'https://github.com/cloudant-labs/clouseau'
#<> Full-text search: clouseau repository tag or hash
default['couch_db']['clouseau']['repo_tag'] = '32b2294d40c5e738b52b3d57d2fb006456bc18cd'

#<> Full-text search: Maven version for CouchDB full-text search. 3.2.5 or earlier REQUIRED.
force_default['maven']['version'] = '3.2.5'
#<> Full-text search: URL to Apache Maven download.
force_default['maven']['url'] = 'https://dist.apache.org/repos/dist/release/maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz'
#<> Full-text search: Apache Maven tarball sha256 checksum
force_default['maven']['checksum'] = '8c190264bdf591ff9f1268dc0ad940a2726f9e958e367716a09b8aaa7e74a755'
#<> Full-text search: Location of m2 home
force_default['maven']['m2_home'] = '/opt/maven'

#<> INTERNAL: Set to true by resource provider if search is enabled.
default['couch_db']['enable_search'] = false
