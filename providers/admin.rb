require 'openssl'

def whyrun_supported?
  true
end

action :create do
  raise 'Password is required for :create action' unless new_resource.password

  template get_config_filename do
    source 'admin.erb'
    cookbook 'couchdb'
    owner 'couchdb'
    group 'couchdb'
    mode 0664
    variables :login => new_resource.login,
              :hash => generate_hash
  end
end

action :delete do
  file get_config_filename do
    action :delete
  end
end

def get_config_filename
  if node['couch_db'].attribute?('config_dir')
    ::File.join(node['couch_db']['config_dir'], 'local.d', "_admin_#{new_resource.login}.ini")
  else
    raise 'Config directory not found. ' +
     'Be sure to run `default` or `source` recipe prior to using couchdb_admin resource'
  end
end

# Generates hash of the password using PBKDF2 algorithm, so it can be used by CouchDB
def generate_hash
  salt = OpenSSL::Random.random_bytes(new_resource.salt_length).unpack('H*')[0]
  iterations = new_resource.iterations
  hash = OpenSSL::PKCS5.pbkdf2_hmac_sha1(new_resource.password,
                                         salt,
                                         iterations, 
                                         new_resource.key_length).unpack('H*')[0]
  "-pbkdf2-#{hash},#{salt},#{iterations}"
end
