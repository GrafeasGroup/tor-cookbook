#
# Cookbook:: tor
# Recipe:: tor_archivist
#
# Copyright:: 2017, Grafeas Group, Ltd., All Rights Reserved.

bugsnag_key = data_bag_item('api_keys', 'bugsnag').fetch('key')
slack_key = data_bag_item('api_keys', 'slack').fetch('key')
bot_info = data_bag_item('bots', 'archivist') || {}

# Shorthand stuff
bot_version = node['tor']['archivist_revision'].gsub(/^v/, '')
pip_whl = ::File.join(Chef::Config[:file_cache_path], "tor_archivist-#{bot_version}-py3-none-any.whl")
base_dir = '/var/tor/tor_archivist'
venv = ::File.join(base_dir, 'venv')
env_file = ::File.join(base_dir, 'environment')

service_is_started = !shell_out('systemctl is-active tor_archivist.service --quiet').error?

directory base_dir do
  owner 'tor_bot'
  group 'bots'
  recursive true
end

virtualenv venv do
  python '/usr/local/bin/python3'

  owner 'tor_bot'
  group 'bots'

  action :create

  not_if { File.exist?(::File.join(venv, 'bin', 'activate')) }
end

template env_file do
  source 'environment_file.erb'

  owner 'root'
  group 'root'
  mode '600'

  sensitive true

  variables(
    bot_name: 'tor_archivist',
    debug_mode: node.chef_environment != 'production',
    redis_uri: 'redis://localhost:6379/0',
    bugsnag_key: bugsnag_key,
    slack_key: slack_key,
    heartbeat_filename: 'heartbeat.port'
  )

  notifies :restart, 'systemd_unit[tor_archivist.service]', :delayed if service_is_started
end

template ::File.join(base_dir, 'praw.ini') do
  source 'praw.ini.erb'

  owner 'tor_bot'
  group 'bots'
  mode '600'

  sensitive true

  variables(
    slug: 'tor_archivist',
    username: bot_info['username'],
    password: bot_info['password'],
    client_id: bot_info['client_id'],
    secret_key: bot_info['secret_key'],
    user_agent_slug: 'archivist',
    version: bot_version
  )

  notifies :restart, 'systemd_unit[tor_archivist.service]', :delayed if service_is_started
end

remote_file pip_whl do
  source "https://github.com/GrafeasGroup/tor_archivist/releases/download/v#{bot_version}/tor_archivist-#{bot_version}-py3-none-any.whl"

  notifies :run, 'execute[install tor_archivist]', :immediately
end

execute 'install tor_archivist' do
  action :nothing

  command <<~EOF
    . #{::File.join(venv, 'bin', 'activate')}
    pip install '#{pip_whl}'
  EOF

  notifies :restart, 'systemd_unit[tor_archivist.service]', :delayed if service_is_started
end

systemd_unit 'tor_archivist.service' do
  content(
    Unit: {
      Description: 'The content curation bot for /r/TranscribersOfReddit',
      Documentation: 'https://github.com/GrafeasGroup/tor_archivist',
      After: 'network.target'
    },
    Service: {
      Type: 'simple',
      EnvironmentFile: env_file,
      ExecStart: ::File.join(venv, 'bin', 'tor-archivist'),
      User: 'tor_bot',
      Group: 'bots',
      WorkingDirectory: base_dir,
      KillSignal: 'SIGINT',
      Restart: 'on-failure',
      TimeoutStopSec: '90', # 90 second timeout after SIGINT before sending a SIGKILL (kill -9)
      StandardOutput: 'syslog',
      StandardError: 'syslog',
      SyslogIdentifier: 'tor_archivist'
    },
    Install: {
      WantedBy: 'multi-user.target'
    }
  )

  action [:create, :enable]
end
