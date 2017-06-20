# encoding: utf-8

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe port(5984) do
  it { should be_listening }
end

describe command('curl http://127.0.0.1:5984/') do
  its('stdout') { should cmp(/"couchdb":"Welcome"/) }
end

describe command('curl http://127.0.0.1:5984/_users') do
  its('stdout') { should cmp(/"db_name":"_users"/) }
end

describe command('curl http://127.0.0.1:5984/_replicator') do
  its('stdout') { should cmp(/"db_name":"_replicator"/) }
end

describe command('curl --user admin:password http://127.0.0.1:5984/_global_changes') do
  its('stdout') { should cmp(/"db_name":"_global_changes"/) }
end
