name              'couchdb'
maintainer        'Joan Touzet'
maintainer_email  'wohali@apache.org'
license           'Apache 2.0'
description       'Installs CouchDB package and starts service'
issues_url        'https://github.com/wohali/couchdb-cookbook/issues'
source_url        'https://github.com/wohali/couchdb-cookbook'
chef_version      '>= 12'
long_description  <<-EOH
Installs the CouchDB package if it is available from an package repository on
the node. If the package repository is not available, CouchDB needs to be
installed via some other method, either a backported package, or compiled
directly from source. CouchDB is available on Red Hat-based systems through
the EPEL Yum Repository.
EOH
version           '2.5.3'
depends           'erlang'
depends           'yum', '~> 3.0'
depends           'yum-epel'
recipe            'couchdb::default', 'Installs and configures CouchDB package'
recipe            'couchdb::source', 'Installs and configures CouchDB from source'

supports          'ubuntu', '~> 12.04'
supports          'ubuntu', '~> 14.04'
supports          'debian', '~> 7.0'
supports          'debian', '~> 8.0'
supports          'openbsd'
supports          'freebsd'

%w(amazon centos debian oracle redhat scientific ubuntu zlinux).each do |_os|
  supports os '~> 6' # requires EPEL Yum Repository
  supports os '~> 7' # requires EPEL Yum Repository
end
