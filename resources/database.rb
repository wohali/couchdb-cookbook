
actions :create, :delete
default_action :create

attribute :database_name, name_attribute: true, kind_of: String, required: true
attribute :database_host, kind_of: String, default: node['couch_db']['config']['httpd']['bind_address']
attribute :database_port, kind_of: Integer, default: node['couch_db']['config']['httpd']['port']
attribute :couchdb_user, kind_of: String, default: nil
attribute :couchdb_password, kind_of: String, default: nil

attr_accessor :exists
