class Chef
  class Recipe
    def couchdb_config(base_dir)
      template File.join(base_dir, 'local.ini') do
        source 'local.ini.erb'
        owner 'couchdb'
        group 'couchdb'
        mode 0660
        variables(
          :config => node['couch_db']['config']
        )
        notifies :restart, 'service[couchdb]'
      end

      # convert to lower case and prepend '~', so it comes last in the config chain
      runtime_config_name = node['couch_db']['runtime_config_name'].downcase
      file File.join(base_dir, 'local.d', "~#{runtime_config_name}.ini") do
        owner 'couchdb'
        group 'couchdb'
        mode 0660
        notifies :restart, 'service[couchdb]'
      end
    end
  end
end
