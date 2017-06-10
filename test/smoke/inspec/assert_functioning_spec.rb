# encoding: utf-8

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe port(5984) do
  it { should be_listening }
end

describe command('curl http://127.0.0.1:5984/') do
  its('stdout') { should cmp(/"couchdb":"Welcome"/) }
end
