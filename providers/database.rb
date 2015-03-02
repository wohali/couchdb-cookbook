
require 'chef/mixin/shell_out'
require 'chef/mixin/language'
require 'json'

def whyrun_supported?
  true
end

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_database
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{ @new_resource }") do
      delete_database
    end
  else
    Chef::Log.info "#{ @current_resource } doesn't exist - can't delete."
  end
end

def load_current_resource

  @current_resource = Chef::Resource::CouchdbDatabase.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.couchdb_user(@new_resource.couchdb_user)
  @current_resource.couchdb_password(@new_resource.couchdb_password)

  if database_exists?(@current_resource.database_name)
    @current_resource.exists = true
  end
end

def create_database
  response = JSON.parse(shellout(create_db_command).stdout)
  response.include("ok")
end

def create_db_command
  if new_resource.couchdb_user == nil && new_resource.couchdb_password == nil
    "curl -X PUT http://#{new_resource.database_host}:#{new_resource.database_port}/#{new_resource.database_name}"
  else
    "curl -X PUT http://#{new_resource.couchdb_user}:#{new_resource.couchdb_password}@#{new_resource.database_host}:#{new_resource.database_port}/#{new_resource.database_name}"
  end
end

def database_exists?(name)
  Chef::Log.debug "Checking to see if the #{new_resource.database_name} database exists."
  result = JSON.parse(`curl -X GET http://#{new_resource.database_host}:#{new_resource.database_port}/_all_dbs`)
  result.include?(new_resource.database_name)
end

