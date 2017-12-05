#
# Cookbook:: tor
# Recipe:: tor_archivist
#
# Copyright:: 2017, Grafeas Group, Ltd., All Rights Reserved.

bugsnag_key = search(:api_keys, 'id:bugsnag').first.fetch('key')
sentry_url = search(:api_keys, 'id:sentry').first.fetch('url')
slack_key = search(:api_keys, 'id:slack').first.fetch('key')

execute 'install archivist' do
  action :nothing

  cwd '/opt/tor_archivist'

  command <<-EOF
  . /opt/virtualenv/bin/activate && pip install --process-dependency-links .
  EOF

  subscribes :run, 'git[/opt/tor_archivist]', :immediately
  notifies :create, 'systemd_unit[tor_archivist.service]', :immediately
  notifies :enable, 'systemd_unit[tor_archivist.service]', :immediately
  notifies :restart, 'systemd_unit[tor_archivist.service]', :delayed
end

template '/var/tor/tor_archivist.env' do
  source 'environment_file.erb'

  variables(
    bot_name: 'tor_archivist',
    debug_mode: node.chef_environment != 'production',
    redis_uri: 'redis://localhost:6379/0',
    bugsnag_api_key: bugsnag_key,
    slack_api_key: slack_key,
    sentry_api_url: sentry_url,
    extra_vars: {
      # None right now, but we'll fill these in as they come up
    }
  )
end

systemd_unit 'tor_archivist.service' do # rubocop:disable Metrics/BlockLength
  content(
    Unit: {
      Description: 'The content curation bot for /r/TranscribersOfReddit',
      Documentation: 'https://github.com/GrafeasGroup/tor_archivist',
      After: 'network.target'
    },
    Service: {
      Type: 'simple',
      EnvironmentFile: '/var/tor/tor_archivist.env',
      ExecStart: '/opt/virtualenv/bin/tor-archivist',
      User: 'tor_bot',
      Group: 'bots',
      WorkingDirectory: '/var/tor',
      KillSignal: 'SIGINT',
      Restart: 'on-failure',
      TimeoutStopSec: '90', # 90 second timeout after SIGINT before sending a SIGKILL (kill -9)
      StandardOutput: 'syslog',
      StandardError: 'syslog'
    },
    Install: {
      WantedBy: 'multi-user.target'
    }
  )

  action :create

  # subscribes :reload_or_try_restart, 'template[/var/tor/praw.ini]', :delayed
  subscribes :reload_or_try_restart, 'template[/var/tor/tor_archivist.env]', :delayed

  only_if { ::File.exist?('/opt/virtualenv/bin/tor-archivist') }
end

git '/opt/tor_archivist' do
  repository 'https://github.com/GrafeasGroup/tor_archivist.git'
  revision node['tor']['archivist_revision']

  action :sync
end
