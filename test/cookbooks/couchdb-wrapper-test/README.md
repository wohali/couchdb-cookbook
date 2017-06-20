# couchdb-wrapper-test

This cookbook includes example wrapper cookbooks for the couchdb
cookbook. These are used by test-kitchen to validate the top-level
cookbook as well.

## Recipes

* `couchdb-wrapper-test::one-node-from-source`: Installs a single node of
  CouchDB on a single machine.
* `couchdb-wrapper-test::three-nodes-from-source`: Installs 3 nodes of
  CouchDB on a single machine and joins the cluster together.
