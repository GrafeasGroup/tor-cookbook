# frozen_string_literal: true
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
  action [:enable, :start]
end

# Copy backup file to restore data
#
# NOTE: This only works because Redis' AOF mode is off.
#
# If AOF is enabled...
# - disable AOF in the redis.conf
# - stop redis service
# - copy over the RDB file (like below)
# - start redis service
# - run `redis-cli config set appendonly yes`
# - re-enable AOF in redis.conf
#
# For simplicity here, let's just keep AOF disabled. (^_^)
file '/var/lib/redis/dump.rdb' do
  content(lazy { ::IO.read('/opt/redis-restore.rdb') })

  owner 'redis'
  group 'redis'

  notifies :stop, 'service[redis]', :before
  notifies :start, 'service[redis]', :immediately

  only_if { ::File.exist?('/opt/redis-restore.rdb') }
  # Make sure we remove the file when done, so a restore isn't triggered every time.
  notifies :delete, 'file[/opt/redis-restore.rdb]', :immediately
end

# This is the location where we will put a restore snapshot.
# Chef will take care of restoring from that snapshot on the next checkin.
file '/opt/redis-restore.rdb' do
  action :nothing
end
