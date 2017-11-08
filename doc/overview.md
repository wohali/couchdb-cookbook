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
