# frozen_string_literal: true
#
# Cookbook:: tor
# Recipe:: tor_ocr
#
# Copyright:: 2017, Grafeas Group, Ltd., All Rights Reserved.

bugsnag_key = data_bag_item(:api_keys, 'bugsnag').fetch('key')
sentry_url = data_bag_item(:api_keys, 'sentry').fetch('url')
slack_key = data_bag_item(:api_keys, 'slack').fetch('key')
ocr_key = data_bag_item(:api_keys, 'ocr_space').fetch('key')
rocketchat = data_bag_item(:api_keys, 'rocketchat')
rocketchat_url = rocketchat.fetch('base_url')
rocketchat_user = rocketchat.fetch('username')
rocketchat_pass = rocketchat.fetch('password')

execute 'install ocr' do
  action :nothing

  cwd '/opt/tor_ocr'

  command <<-EOF
  . /opt/virtualenv/bin/activate && pip install --process-dependency-links -e .
  EOF

  subscribes :run, 'git[/opt/tor_ocr]', :immediately
  notifies :create, 'systemd_unit[tor_ocr.service]', :immediately
  notifies :enable, 'systemd_unit[tor_ocr.service]', :immediately
  notifies :restart, 'systemd_unit[tor_ocr.service]', :delayed unless node.chef_environment == 'dev'
end

template '/var/tor/tor_ocr.env' do
  source 'environment_file.erb'

  owner 'tor_bot'
  group 'bots'

  sensitive true

  variables(
    bot_name: 'tor_ocr',
    debug_mode: node.chef_environment != 'production',
    redis_uri: 'redis://localhost:6379/0',
    bugsnag_key: bugsnag_key,
    slack_key: slack_key,
    sentry_url: sentry_url,
    heartbeat_filename: 'ocr.heartbeat',
    rocketchat_url: rocketchat_url,
    rocketchat_user: rocketchat_user,
    rocketchat_pass: rocketchat_pass,
    extra_variables: {
      'OCR_API_KEY' => ocr_key,
    }
  )
end

systemd_unit 'tor_ocr.service' do
  content(
    Unit: {
      Description: 'The transcription guesser bot for /r/TranscribersOfReddit',
      Documentation: 'https://github.com/GrafeasGroup/tor_ocr',
      After: 'network.target',
    },
    Service: {
      Type: 'simple',
      EnvironmentFile: '/var/tor/tor_ocr.env',
      ExecStart: '/opt/virtualenv/bin/tor-apprentice',
      User: 'tor_bot',
      Group: 'bots',
      WorkingDirectory: '/var/tor',
      KillSignal: 'SIGINT',
      Restart: 'on-failure',
      TimeoutStopSec: '90', # 90 second timeout after SIGINT before sending a SIGKILL (kill -9)
      StandardOutput: 'syslog',
      StandardError: 'syslog',
      SyslogIdentifier: 'tor_ocr',
    },
    Install: {
      WantedBy: 'multi-user.target',
    }
  )

  action :create

  # subscribes :reload_or_try_restart, 'template[/var/tor/praw.ini]', :delayed
  subscribes :reload_or_try_restart, 'template[/var/tor/tor_ocr.env]', :delayed unless node.chef_environment == 'dev'

  only_if { ::File.exist?('/opt/virtualenv/bin/tor-apprentice') }
end

git '/opt/tor_ocr' do
  repository 'https://github.com/GrafeasGroup/tor_ocr.git'
  revision node['tor']['ocr_revision']

  action :sync
end
