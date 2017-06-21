[![Build Status](https://travis-ci.org/wohali/couchdb-cookbook.svg?branch=master)](https://travis-ci.org/wohali/couchdb-cookbook)

# Description

Installs and configures Apache CouchDB 2.x from source, optionally enabling
full-text search capabilities.

# Requirements

Requires a platform that can install Erlang from distribution packages
provided by Erlang Solutions (`erlang::esl` recipe is used)

## Platform

This cookbook supports the following platforms, verified via Test Kitchen:

* CentOS 7.3
* Debian 7.11 (wheezy), 8.7 (jessie)
* Ubuntu 14.04 (trusty), 16.04 (xenial)

*NOTE*: This recipe cannot automatically install JDK 6 for Debian 8 and
Ubuntu 16. Please ensure this prerequisite is managed by roles preceeding
this one for your nodes if you wish to enable fulltext search ability.

## Cookbooks

This cookbook depends on the following external cookbooks:
* `build-essential`
* `compat_resource`
* `erlang`
* `nodejs`
* `poise-python`
* `yum-epel` (RHEL-flavoured distributions only)
* If fulltext search is enabled:
  * `java`
  * `maven`

Everything below this line is not yet updated for the 3.0.0 cookbook
release!

-------------------

# Resources

`couchdb_node` - TBD
`couchdb_clouseau` - Internal search provider used by `couchdb_node`. Not
intended for direct use in wrapper cookbooks.

# Attributes

Cookbook attributes are named under the `couch_db` keyspace.

* `node['couch_db']['src_checksum']` - sha256sum of the default version of couchdb to download
* `node['couch_db']['src_version']` - default version of couchdb to download, used in the full URL to download.
* `node['couch_db']['src_mirror']` - full URL to download.
* `node['couch_db']['install_erlang']` - specify if erlang should be installed prior to
  couchdb, true by default.

## Configuration - CURRENTLY DISABLED

The `local.ini` file is dynamically generated from attributes. Each key in
`node['couch_db']['config']` is a CouchDB configuration directive, and will
be rendered in the config file. For example, the attribute:

    node['couch_db']['config']['httpd']['bind_address'] = "0.0.0.0"

Will result in the following lines in the `local.ini` file:

    [httpd]
    bind_address = "0.0.0.0"

The attributes file contains default values for platform-independent parameters.
All parameter values that expect a path argument are not set by default. The
default values that are currently set have been taken from the CouchDB
configuration [wiki
page](http://wiki.apache.org/couchdb/Configurationfile_couch.ini).

The resulting configuration file is now dynamically rendered from the
attributes. Each subkey below the `config` key is a specific section of the
`local.ini` file. Then each subkey in a section is a parameter associated with a
value.

You should consult the CouchDB documentation for specific configuration details.

For values that are "on" or "off", they should be specified as literal `true` or
`false`. Any configuration option set to the literal `nil` will be skipped
entirely. All other values (e.g., string, numeric literals) will be used as is.
So for example:

    node.default['couch_db']['config']['couchdb']['os_process_timeout'] = 5000
    node.default['couch_db']['config']['couchdb']['delayed_commits'] = true
    node.default['couch_db']['config']['couchdb']['batch_save_interval'] = nil
    node.default['couch_db']['config']['httpd']['port'] = 5984
    node.default['couch_db']['config']['httpd']['bind_address'] = "127.0.0.1"

Will result in the following config lines:

    [couchdb]
    os_process_timeout = 5000
    delayed_commits = true

    [httpd]
    port = 5984
    bind_address = 127.0.0.1

(no line printed for `batch_save_interval` as it is `nil`)

### Defaults

Here the list of attributes that are already provided by the recipe and their
associated default value.

#### Section [couchdb]

* `node['couch_db']['config]['couchdb']['max_document_size']` -
   Maximum size of a document in bytes, defaults to `4294967296` (`4 GB`).
* `node['couch_db']['config]['couchdb']['max_attachment_chunk_size']` -
   Maximum chunk size of an attachment in bytes, defaults to `4294967296` (`4 GB`).
* `node['couch_db']['config]['couchdb']['os_process_timeout']` -
   OS process timeout for view and external servers in milliseconds, defaults to `5000` (`5 seconds`).
* `node['couch_db']['config]['couchdb']['max_dbs_open']` -
   Upper bound limit on the number of databases that can be open at one time, defaults to `100`.
* `node['couch_db']['config]['couchdb']['delayed_commits']` -
   Determines if commits should be delayed, defaults to `true`.
* `node['couch_db']['config]['couchdb']['batch_save_size']` -
   Number of document at which to save a batch, defaults to `1000`.
* `node['couch_db']['config]['couchdb']['batch_save_interval']` -
   Interval after which to save batches in milliseconds, default to `1000` (`1 second`).

#### Section [httpd]

* `node['couch_db']['config']['httpd']['port']` -
   Port CouchDB should bind to, defaults to `5984`.
* `node['couch_db']['config']['httpd']['bind_address']` -
   IP address CouchDB should bind to, defaults to `127.0.0.1`.

#### Section [log]

* `node['couch_db']['config']['log']['level']` -
   CouchDB's log level, defaults to `info`.

Recipes
=======

default
-------

Installs the couchdb package, creates the data directory and starts the couchdb service.

source
------

Downloads the CouchDB source from the Apache project site, plus development dependencies. Then builds the binaries for installation, creates a user and directories, then sets up the couchdb service. Uses the init script provided in the cookbook.

LWRPs
=====

database
--------
Can be used to create a database on a CouchDB install.

* `database_name` - name of the database to create.
* `database_host` - host name or IP address of the database server.
* `database_port` - TCP port of the database server.
* `couchdb_user` - username to bind to the CouchDB server with (optional).
* `couchdb_password` - password to bind to the CouchDB server with (optional).


License and Author
==================

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License.  You may obtain a copy of the
License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied.  See the License for the
specific language governing permissions and limitations under the License.

* Author: Joshua Timberman (<joshua@opscode.com>)
* Author: Matthieu Vachon (<matthieu.o.vachon@gmail.com>)
* Author: Joan Touzet (<wohali@apache.org>)

Copyright 2009-2014, Opscode, Inc.
Copyright 2014-2017, Joan Touzet

