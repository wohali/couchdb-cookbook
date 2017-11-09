name              'couchdb'
maintainer        'Joan Touzet'
maintainer_email  'wohali@apache.org'
license           'Apache-2.0'
description       'Installs CouchDB 2.0 from package or source'
issues_url        'https://github.com/wohali/couchdb-cookbook/issues'
source_url        'https://github.com/wohali/couchdb-cookbook'
chef_version      '>= 12'
long_description  <<-EOH
Installs the CouchDB package either from a package repository (default recipe)
or direct from source code (source recipe). Convenience LWRPs are provided to
create databases as well.
EOH
version           '3.0.3'

depends           'build-essential'
depends           'compat_resource'
depends           'erlang'
depends           'poise-python'
depends           'yum-epel'
depends           'java'  # only for full-text search
depends           'maven' # only for full-text search

supports          'ubuntu', '>= 14.04'
supports          'debian', '>= 7.0'
supports          'amazon', '>= 7.0' # requires EPEL Yum Repository
supports          'centos', '>= 7.0' # requires EPEL Yum Repository
supports          'oracle', '>= 7.0' # requires EPEL Yum Repository
supports          'redhat', '>= 7.0' # requires EPEL Yum Repository
supports          'scientific', '>= 7.0' # requires EPEL Yum Repository
supports          'zlinux', '>= 7.0' # requires EPEL Yum Repository
# supports          'openbsd'
# supports          'freebsd'
