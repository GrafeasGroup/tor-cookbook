# frozen_string_literal: true
#
# Cookbook:: tor
# Recipe:: backup
#
# Copyright:: 2018, Grafeas Group, Ltd., All Rights Reserved.

backup = data_bag_item('api_keys', 'backup') # TODO: create data bag item

directory '/root/.ssh' do
  recursive true
  owner 'root'
  group 'root'
  mode '0700'
  action :create
end

template '/root/.ssh/config' do
  source 'root.sshconfig.erb'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

file '/root/.ssh/backup_id_rsa' do
  content(backup.fetch('backup_id_rsa'))

  owner 'root'
  group 'root'
  mode '0600'
  action :create
end

file '/root/.ssh/backup_id_rsa.pub' do
  content(backup.fetch('backup_id_rsa.pub'))

  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

directory '/root/bin' do
  recursive true
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file '/root/bin/backup-redis' do
  if node.chef_environment == 'dev'
    source 'noop.sh'
  else
    source 'backup-redis.sh'
  end

  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

systemd_unit 'backup_tor_data.service' do
  content(
    Unit: {
      Description: 'Backs up ToR data to offsite location for disaster recovery',
      After: 'network.target',
    },
    Service: {
      Type: 'simple',
      ExecStart: '/root/bin/backup-redis', # this has to be run by root because of permissions of the redis dump
      User: 'root',
      StandardOutput: 'syslog',
      StandardError: 'syslog',
      SyslogIdentifier: 'backup_tor',
    }
  )

  action :create
end

systemd_unit 'backup_tor_data.timer' do
  content(
    Unit: {
      Description: 'Sets backup schedule for ToR data',
      After: 'network.target',
    },
    Timer: {
      OnCalendar: '*-*-* 1,4,7,10,13,16,19,22:00:00', # Every 3 hours
      RandomizedDelaySec: '15 minutes',
      Persistent: true, # If timer is ever disabled, trigger once on load to "catch up" for missed times it should have fired (max of firing off once)
      Unit: 'backup_tor_data.service', # This is implicit with systemd, but best to put it here for clarity
    },
    Install: {
      WantedBy: 'multi-user.target',
    }
  )

  action [:create, :enable, :start]
end
