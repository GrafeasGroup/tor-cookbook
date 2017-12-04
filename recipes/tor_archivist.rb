#
# Cookbook:: tor
# Recipe:: tor_archivist
#
# Copyright:: 2017, Grafeas Group, Ltd., All Rights Reserved.

execute 'install archivist' do
  action :nothing

  cwd '/opt/tor_archivist'

  command <<-EOF
  . /opt/virtualenv/bin/activate && pip install --process-dependency-links .
  EOF

  subscribes :run, 'git[/opt/tor_archivist]', :immediately
end

template '/var/tor/tor_archivist.env' do
  source 'environment_file.erb'

  variables(
    bot_name: 'tor_archivist',
    debug_mode: !node.chef_environment.casecmp('production'),
    extra_vars: {
      # None right now, but we'll fill these in as they come up
    }
  )
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
      ExecStart: '/opt/virtualenv/bin/tor-archivist',
      EnvironmentFile: '/var/tor/tor_archivist.env',
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

  subscribes :reload_or_try_restart, 'template[/var/tor/praw.ini]', :delayed
end

git '/opt/tor_archivist' do
  repository 'https://github.com/GrafeasGroup/tor_archivist.git'
  revision node['tor']['archivist_revision']

  action :sync
end
