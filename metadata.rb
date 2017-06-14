name              'couchdb'
maintainer        'Joan Touzet'
maintainer_email  'wohali@apache.org'
license           'Apache 2.0'
description       'Installs CouchDB 2.0 from package or source'
issues_url        'https://github.com/wohali/couchdb-cookbook/issues'
source_url        'https://github.com/wohali/couchdb-cookbook'
chef_version      '>= 12'
long_description  <<-EOH
Installs the CouchDB package either from a package repository (default recipe) 
or direct from source code (source recipe). Convenience LWRPs are provided to
create databases as well.
EOH
version           '3.0.0'
depends           'erlang'
depends           'yum', '~> 3.0'
depends           'yum-epel'
recipe            'couchdb::default', 'Installs and configures CouchDB package'
recipe            'couchdb::source', 'Installs and configures CouchDB from source'

supports          'ubuntu', '>= 12.04'
supports          'debian', '>= 7.0'
supports          'openbsd'
supports          'freebsd'
supports          'amazon', '>= 6.0' # requires EPEL Yum Repository
supports          'centos', '>= 6.0' # requires EPEL Yum Repository
supports          'oracle', '>= 6.0' # requires EPEL Yum Repository
supports          'redhat', '>= 6.0' # requires EPEL Yum Repository
supports          'scientific', '>= 6.0' # requires EPEL Yum Repository
supports          'zlinux', '>= 6.0' # requires EPEL Yum Repository
