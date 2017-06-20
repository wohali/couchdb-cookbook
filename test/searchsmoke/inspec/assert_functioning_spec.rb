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

# make a database with 2 docs and a ddoc
describe command('curl -X PUT --user admin:password localhost:5984/foo') do
  its('stdout') { should cmp(/"ok":true/) }
end
describe command('curl -X PUT --user admin:password localhost:5984/foo/robert -d \'{"_id":"robert","name":"robert newson"}\'') do
  its('stdout') { should cmp(/"ok":true/) }
end
describe command('curl -X PUT --user admin:password localhost:5984/foo/joan -d \'{"_id":"joan","name":"joan touzet"}\'') do
  its('stdout') { should cmp(/"ok":true/) }
end
describe command('curl -X PUT --user admin:password localhost:5984/foo/_design/ddoc -d \'{"_id":"_design/ddoc","views":{"new-view":{"map":"function (doc) {\n emit(doc._id, 1);\n}"}},"indexes":{"names":{"index":"function(doc) {\n index(\"default\", doc._id);\n if(doc.name) {\n index(\"name\", doc.name, {\"store\": true});\n }\n}"}},"language":"javascript"}\'') do
  its('stdout') { should cmp(/"ok":true/) }
end

# test search - may take a while...
describe command('bash -c \'for i in {1..5}; do curl "http://localhost:5984/foo/_design/ddoc/_search/names?q=name:j*" | grep total_rows && break || sleep 30; done\'') do
  its('stdout') { should cmp(/"total_rows":1/) }
end
