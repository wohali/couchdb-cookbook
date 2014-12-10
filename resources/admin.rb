#
# Cookbook Name:: couchdb
# Resource:: admin
#
# Author:: Artur Nowak (<artur.nowak@evidenceprime.com>)

actions :create, :delete
default_action :create

attribute :login, :kind_of       => String, :name_attribute => true, :required => true
attribute :password, :kind_of    => String
attribute :salt_length, :kind_of => Fixnum, :default  => 16
attribute :iterations, :kind_of  => Fixnum, :default  => 10
attribute :key_length, :kind_of  => Fixnum, :default  => 20
