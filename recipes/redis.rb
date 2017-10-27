#
# Cookbook:: tor
# Recipe:: redis
#
# Copyright:: 2017, Grafeas Group, Ltd., All Rights Reserved.

package 'epel-release' do
  action :install
end

package 'redis' do
  action :install
end

service 'redis' do
  action %i[enable start]
end
