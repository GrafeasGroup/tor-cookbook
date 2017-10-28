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

admin_settings = search(:sysadmins, '*:*') || []

admin_settings.each do |admin|
  user admin['id'] do
    comment 'administrative user'
    home "/home/#{admin['id']}"
    shell admin.fetch('shell', '/bin/bash')
    manage_home true
    password admin['shadow_passwd']
    action :create
  end
end

group 'sudo' do
  members(admin_settings.map { |u| u['id'] })
  append true
  action :create
end
