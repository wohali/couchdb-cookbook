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
default['couch_db']['src_version']    = '2.1.1'
#<> Apache CouchDB download link.
default['couch_db']['src_mirror']     = "https://archive.apache.org/dist/couchdb/source/#{node['couch_db']['src_version']}/apache-couchdb-#{node['couch_db']['src_version']}.tar.gz"
#<> sha256 checksum of Apache CouchDB tarball.
default['couch_db']['src_checksum']   = 'd5f255abc871ac44f30517e68c7b30d1503ec0f6453267d641e00452c04e7bcc'

#<> Whether CouchDB installation will install Erlang or not.
default['couch_db']['install_erlang'] = true
#<> Method of Erlang installation - `esl` is recommended.
node.default['erlang']['install_method'] = 'esl'
#<> Version of `esl` package to install.
node.default['erlang']['esl']['version'] = if node['platform_family'] == 'rhel'
                                             '18.3-1'
                                           elsif node['platform_family'] == 'debian'
                                             if node['platform_version'].to_f >= 9.0
                                               '1:19.3.6'
                                             else
                                               '1:18.3'
                                             end
                                           end

#<> CouchDB configure options.
default['couch_db']['configure_flags'] = '-c'

#<> Full-text search: dreyfus repository URL
default['couch_db']['dreyfus']['repo_url'] = 'https://github.com/cloudant-labs/dreyfus'
#<> Full-text search: dreyfus repository tag or hash
default['couch_db']['dreyfus']['repo_tag'] = '30b0556047d54795a5b5cfe96a7bc4b75145bb06'
#<> Full-text search: clouseau repository URL
default['couch_db']['clouseau']['repo_url'] = 'https://github.com/cloudant-labs/clouseau'
#<> Full-text search: clouseau repository tag or hash
default['couch_db']['clouseau']['repo_tag'] = 'f2a324bef93d1b5b3c72e3046193bd6782da36c4'

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
