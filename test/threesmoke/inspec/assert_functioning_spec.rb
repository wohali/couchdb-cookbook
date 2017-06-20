# encoding: utf-8

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe port(15984) do
  it { should be_listening }
end
describe port(25984) do
  it { should be_listening }
end
describe port(35984) do
  it { should be_listening }
end

describe command('curl http://127.0.0.1:15984/') do
  its('stdout') { should cmp(/"couchdb":"Welcome"/) }
end
describe command('curl http://127.0.0.1:25984/') do
  its('stdout') { should cmp(/"couchdb":"Welcome"/) }
end
describe command('curl http://127.0.0.1:35984/') do
  its('stdout') { should cmp(/"couchdb":"Welcome"/) }
end

# TODO: check _membership
# TODO: check _users is present
