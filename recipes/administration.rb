#
# Cookbook:: tor
# Recipe:: administration
#
# Copyright:: 2017, Grafeas Group, Ltd., All Rights Reserved.

# include_recipe 'chef-client::service'

cookbook_file '/etc/sudoers.d/sudoers' do
  source 'sudoers'
  owner 'root'
  group 'root'
  mode '0440'
end

node[cookbook_name]['admin_users'].each do |username|
  execute "nonce-password-#{username}" do
    command "chage -d0 #{username}"
    action :nothing

    not_if "chage -l | grep -q 'Password expires *: *password must be changed'"
  end

  user username do
    comment 'administrative user'
    home "/home/#{username}"
    shell '/bin/bash'
    manage_home true
    password node[cookbook_name]['default_password']
    action :create

    notifies :run, "execute[nonce-password-#{username}]", :immediately

    not_if { File.exist?("/home/#{username}") }
  end
end

group 'sudo' do
  members node[cookbook_name]['admin_users']
  append true
  action :create
end
