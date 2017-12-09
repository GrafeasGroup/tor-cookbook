#
# Cookbook:: tor
# Recipe:: administration
#
# Copyright:: 2017, Grafeas Group, Ltd., All Rights Reserved.

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

  directory "/home/#{admin['id']}/.ssh" do
    owner admin['id']
    group admin['id']
    mode '0700'
  end

  file "/home/#{admin['id']}/.ssh/authorized_keys" do
    content admin['public_key']

    owner admin['id']
    group admin['id']
    mode '0600'
    sensitive true
  end
end

group 'sudo' do
  members(admin_settings.map { |u| u['id'] })
  append true
  action :create
end
