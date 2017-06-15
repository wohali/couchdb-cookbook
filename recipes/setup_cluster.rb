# TODO: Header here

# Install httparty gem for usage within Chef runs
chef_gem 'httparty' do
  # as per https://www.chef.io/blog/2015/02/17/chef-12-1-0-chef_gem-resource-warnings/
  compile_time false if Chef::Resource::ChefGem.method_defined?(:compile_time)
  action :install
  compile_time false
end
