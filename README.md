# Description

[![Build Status](https://travis-ci.org/wohali/couchdb-cookbook.svg?branch=master)](https://travis-ci.org/wohali/couchdb-cookbook)

The CouchDB Cookbook is a library cookbook that provides custom resources for
use in recipes, designed to install and configure Apache CouchDB 2.x from
source, optionally enabling full-text search capabilities.

It includes reference examples illustrating how to install and configure a
standalone CouchDB server, or a full cluster of joined CouchDB server nodes.

# Platform Support

The following platforms have been tested with Test Kitchen:

* CentOS 7.3
* Debian 7.11 (wheezy), 8.7 (jessie)
* Ubuntu 14.04 (trusty), 16.04 (xenial)

Partial support is provided for the following platforms:

* Debian 9.x (stretch) - search not yet supported
* Ubuntu 17.10 (artful) - search not yet supported

Pull requests to add support for other platforms are most welcome.

*NOTE*: This recipe cannot automatically install JDK 6 for Debian 8 and
Ubuntu 16. Please ensure this prerequisite is managed by roles preceeding
this one for your nodes if you wish to enable fulltext search ability.

# Examples

The test cookbooks under `test/cookbooks/couchdb-wrapper-test/recipes/` include
worked examples of how to include the CouchDB resources in your own cookbooks.
Here are a few excerpts.

## Standalone (single-node) CouchDB

For a single CouchDB server, use the `couchdb_node` resource once:

```ruby
couchdb_node 'couchdb' do
  admin_username 'admin'
  admin_password 'password'
  type 'standalone'
end
```

The `fulltext true` attribute can be added to enable full-text search
functionality.

## Clustered CouchDB nodes

All nodes in the cluster must have the same `uuid`, `cookie`, `admin_username`
and `admin_password`.

It is recommended to pre-generate the UUID and place it in
your cookbook. The following one-liner will generate a CouchDB UUID:

```bash
python -c "import uuid;print(uuid.uuid4().hex)"
```

Further, if you want session cookies from one node to work on another (for
instance, when putting a load balancer in front of CouchDB) the _hashed_ admin
password must match on every machine as well. There are many ways to
pre-generate a hashed password. One way is by downloading and extracting
CouchDB's source code, changing into the `dev/` directory, and running the
following one-liner, replacing `MYPASSWORD` with your desired password:

```bash
python -c 'import uuid;from pbkdf2 import pbkdf2_hex;password="MYPASSWORD";salt=uuid.uuid4().hex;iterations=10;print("-pbkdf2-{},{},{}".format(pbkdf2_hex(password,salt,iterations,20),salt,iterations))'
```

Place this hashed password in your recipe, cookbook, data bag, encrypted data
bag, vault, etc.

For each machine to run a CouchDB clustered node, use a block of the form:

```ruby
uuid = <uuid_goes_here>

couchdb_node 'couchdb' do
  type 'clustered'
  uuid uuid
  cookie 'henriettapussycat'
  admin_username 'admin'
  admin_password 'password'
end
```

A _single node_ in the cluster must also include the `couchdb_setup_cluster`
resource. *DO NOT run this resource on all nodes in the cluster.*

The `couchdb_setup_cluster` resource uses Chef Search to determine which nodes
to include in the cluster. By default, it searches for nodes with the role
specified in the `role` attribute. If desired, the search string can be
completely overridden with the `search_string` attribute.

Additionally, the number of nodes expected to be retrieved from Chef Search must
be specified in the `num_nodes` attribute. This prevents prematurely finalising
cluster setup before all nodes have been converged by Chef.

This example joins exactly 3 nodes with the role `my_couchdb_role` into a
cluster:

```ruby
couchdb_setup_cluster 'doit' do
  admin_username 'admin'
  admin_password 'password'
  role 'my_couchdb_role'
  num_nodes 3
end
```

## Development "3-in-1" server

For development purposes, it is often useful to run a 3-node cluster on a single
machine to ensure that applications correctly respond to cluster-like CouchDB
behaviour. The recipe
`test/cookbooks/couchdb-wrapper-test/recipes/three-nodes-from-source.rb` is a
full example of how this can be done, and is used by Test Kitchen in the
verification of this cookbook.

# Requirements

* Chef 12 or higher
* Network-accessible package repositories
* EPEL repositories on RHEL platforms

## Platform:

* ubuntu (>= 14.04)
* debian (>= 7.0)
* amazon (>= 7.0)
* centos (>= 7.0)
* oracle (>= 7.0)
* redhat (>= 7.0)
* scientific (>= 7.0)
* zlinux (>= 7.0)

## Cookbooks:

* build-essential
* compat_resource
* erlang
* poise-python
* yum-epel
* java
* maven

# Attributes

* `node['couch_db']['src_version']` - Apache CouchDB version to download. Defaults to `2.1.1`.
* `node['couch_db']['src_mirror']` - Apache CouchDB download link. Defaults to `https://archive.apache.org/dist/couchdb/source/#{node['couch_db']['src_version']}/apache-couchdb-#{node['couch_db']['src_version']}.tar.gz`.
* `node['couch_db']['src_checksum']` - sha256 checksum of Apache CouchDB tarball. Defaults to `d5f255abc871ac44f30517e68c7b30d1503ec0f6453267d641e00452c04e7bcc`.
* `node['couch_db']['install_erlang']` - Whether CouchDB installation will install Erlang or not. Defaults to `true`.
* `node['couch_db']['configure_flags']` - CouchDB configure options. Defaults to `-c`.
* `node['couch_db']['dreyfus']['repo_url']` - Full-text search: dreyfus repository URL. Defaults to `https://github.com/cloudant-labs/dreyfus`.
* `node['couch_db']['dreyfus']['repo_tag']` - Full-text search: dreyfus repository tag or hash. Defaults to `d83888154be546b2826b3346a987089a64728ee5`.
* `node['couch_db']['clouseau']['repo_url']` - Full-text search: clouseau repository URL. Defaults to `https://github.com/cloudant-labs/clouseau`.
* `node['couch_db']['clouseau']['repo_tag']` - Full-text search: clouseau repository tag or hash. Defaults to `32b2294d40c5e738b52b3d57d2fb006456bc18cd`.
* `node['maven']['version']` - Full-text search: Maven version for CouchDB full-text search. 3.2.5 or earlier REQUIRED. Defaults to `3.2.5`.
* `node['maven']['url']` - Full-text search: URL to Apache Maven download. Defaults to `https://dist.apache.org/repos/dist/release/maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz`.
* `node['maven']['checksum']` - Full-text search: Apache Maven tarball sha256 checksum. Defaults to `8c190264bdf591ff9f1268dc0ad940a2726f9e958e367716a09b8aaa7e74a755`.
* `node['maven']['m2_home']` - Full-text search: Location of m2 home. Defaults to `/opt/maven`.
* `node['couch_db']['enable_search']` - INTERNAL: Set to true by resource provider if search is enabled. Defaults to `false`.

# Recipes

* [couchdb::compile](#couchdbcompile) - INTERNAL USE ONLY.
* [couchdb::prereq](#couchdbprereq) - INTERNAL USE ONLY.

## couchdb::compile

INTERNAL USE ONLY. Downloads and compiles CouchDB from source.

## couchdb::prereq

INTERNAL USE ONLY. Creates directories, users, and installs runtime and build
prerequisites for CouchDB when installing from source.

# Resources

* [couchdb_clouseau](#couchdb_clouseau) - This creates and destroys a CouchDB Clouseau (search) node, and is automatically invoked by the `couchdb_node` resource.
* [couchdb_node](#couchdb_node) - This creates a CouchDB node, either standalone or as part of a cluster.
* [couchdb_setup_cluster](#couchdb_setup_cluster) - Optional role to join all nodes in the cluster together.

## couchdb_clouseau

This creates and destroys a CouchDB Clouseau (search) node, and is automatically
invoked by the `couchdb_node` resource. There is *no need* to include this resource
directly in your wrapper cookbook.

### Actions

- create: Create the CouchDB Clouseau node. Default action.

### Attribute Parameters

- bind_address: The address on which the clouseau service will bind. Defaults to <code>"127.0.0.1"</code>.
- index_dir: The directory in which the clouseau service will store its indexes. Defaults to <code>"default"</code>.
- cookie: The Erlang cookie with which the clouseau service will join the cluster. Defaults to <code>"monster"</code>.

## couchdb_node

This creates a CouchDB node, either standalone or as part of a cluster.

### Actions

- create: Create the CouchDB node. Default action.

### Attribute Parameters

- bind_address: The address to which CouchDB will bind. Defaults to <code>"0.0.0.0"</code>.
- port: The port to which CouchDB will bind the main interface. Defaults to <code>5984</code>.
- local_port: The port to which CouchDB will bind the node-local (backdoor) interface. Defaults to <code>5986</code>.
- admin_username: The administrator username for CouchDB. In a cluster, all nodes should have the same administrator.
- admin_password: The administrator password for CouchDB. In a cluster, all nodes should have the same administrator.
- uuid: The UUID for the node. In a cluster, all node UUIDs must match. Auto-generated if not specified.
- cookie: The cookie for the node. In a cluster, all node cookies must match. Defaults to <code>"monster"</code>.
- type: The type of the node - `standalone` or `clustered`. Defaults to <code>"clustered"</code>.
- loglevel: The logging level of the node. Defaults to <code>"info"</code>.
- config: A hash specifying additional settings for the CouchDB configuration ini files. The first level of the hash represents section headings. The second level contains key-pair values to place in the ini file. See `test/cookbooks/couchdb-wrapper-test/recipes/one-node-from-source.rb` for more detail. Defaults to <code>{}</code>.
- fulltext: Whether to enable full-text search functionality or ont. Defaults to <code>false</code>.
- extra_vm_args: Additional Erlang launch arguments to place in the `vm.args` file. Can be used to specify `inet_dist_listen_min`, `inet_dist_listen_max` and `inet_dist_use_interface` options, for example.

### Examples

    # Standalone node with full-text search enabled.
    couchdb_node 'couchdb' do
      admin_username 'admin'
      admin_password 'password'
      fulltext true
      type 'standalone'
    end

## couchdb_setup_cluster

Optional role to join all nodes in the cluster together.

NOTE: Intended to be run on a SINGLE NODE IN THE CLUSTER. Adding this to
the run list of more than one node in the cluster will result in undefined,
probably WRONG behaviour.

Through the use of the `address` and `port` options, this resource can be
run on any Chef-managed machine. It does not have to run on a CouchDB node.

Operators can also avoid this role and manage cluster membership and
finalisation outside of Chef.

### Actions

- create:  Default action.

### Attribute Parameters

- address: The CouchDB address through which cluster management is performed. Defaults to <code>"127.0.0.1"</code>.
- port: The port for the CouchDB address through which cluster management is performed. Defaults to <code>5984</code>.
- admin_username: The administrator username for CouchDB. In a cluster, all nodes should have the same administrator.
- admin_password: The administrator password for CouchDB. In a cluster, all nodes should have the same administrator.
- role: The role to which all nodes in the cluster should belong. Used with Chef Search to retrieve a current list of node addresses and ports. Defaults to <code>"couchdb"</code>.
- search_string: Override of the default `roles:<role>` Chef Search expression. Modify this if you need to build a list of nodes in the cluster via different search terms. Defaults to <code>"default"</code>.
- num_nodes: Required. Number of nodes the Chef Search should return. Ensures that all nodes have been provisioned prior to joining them into a cluster.
- node_list: Optional array of [address, port] pairs representing all nodes in the cluster. If a static list is specified here, it will override the Chef Search. Only these nodes will be joined into the cluster. Only use this as a last resort. Example: `[['127.0.0.1', 15984], ['127.0.0.1', 25984], ['127.0.0.1', 35984]]`. Defaults to <code>[]</code>.

# License and Maintainer

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License.  You may obtain a copy of the
License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied.  See the License for the
specific language governing permissions and limitations under the License.

* Author: Joan Touzet (<wohali@apache.org>)
* Previous Authors:
  * Joshua Timberman (<joshua@opscode.com>)
  * Matthieu Vachon (<matthieu.o.vachon@gmail.com>)

Copyright 2014-2017, Joan Touzet; Copyright 2009-2014, Opscode, Inc.
