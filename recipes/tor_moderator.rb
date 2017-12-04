#
# Cookbook:: tor
# Recipe:: tor_moderator
#
# Copyright:: 2017, Grafeas Group, Ltd., All Rights Reserved.

execute 'install tor' do
  action :nothing

  cwd '/opt/tor'

  command <<-EOF
  . /opt/virtualenv/bin/activate && pip install --process-dependency-links .
  EOF

  subscribes :run, 'git[/opt/tor]', :immediately
  notifies :create, 'systemd_unit[tor_moderator.service]', :immediately
  notifies :enable, 'systemd_unit[tor_moderator.service]', :immediately
  notifies :restart, 'systemd_unit[tor_moderator.service]', :delayed
end

log node.chef_environment

template '/var/tor/tor_moderator.env' do
  source 'environment_file.erb'

  variables(
    bot_name: 'tor',
    debug_mode: node.chef_environment != 'production',
    redis_uri: 'redis://localhost:6379/0',
    bugsnag_api_key: '',
    slack_api_key: '',
    sentry_api_url: '',
    extra_vars: {
      # None right now, but we'll fill these in as they come up
    }
  )
end

systemd_unit 'tor_moderator.service' do # rubocop:disable Metrics/BlockLength
  content(
    Unit: {
      Description: 'The claim, done, and scoring bot for /r/TranscribersOfReddit',
      Documentation: 'https://github.com/GrafeasGroup/tor',
      After: 'network.target'
    },
    Service: {
      Type: 'simple',
      EnvironmentFile: '/var/tor/tor_moderator.env',
      ExecStart: '/opt/virtualenv/bin/tor-moderator',
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
  subscribes :reload_or_try_restart, 'template[/var/tor/tor_moderator.env]', :delayed

  only_if { ::File.exist?('/opt/virtualenv/bin/tor-moderator') }
end

git '/opt/tor' do
  repository 'https://github.com/GrafeasGroup/tor.git'
  revision node['tor']['tor_revision']

  action :sync
end
