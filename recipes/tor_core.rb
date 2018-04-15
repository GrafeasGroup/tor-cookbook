# frozen_string_literal: true
#
# Cookbook:: tor
# Recipe:: tor_core
#
# Copyright:: 2017, Grafeas Group, Ltd., All Rights Reserved.

execute 'install tor_core' do
  action :nothing

  cwd '/opt/tor_core'

  command <<-EOF
  . /opt/virtualenv/bin/activate && pip install --process-dependency-links -e .
  EOF

  subscribes :run, 'git[/opt/tor_core]', :immediately
  notifies :restart, 'systemd_unit[tor_moderator.service]', :delayed
  notifies :restart, 'systemd_unit[tor_archivist.service]', :delayed
  notifies :restart, 'systemd_unit[tor_ocr.service]', :delayed
end

git '/opt/tor_core' do
  repository 'https://github.com/GrafeasGroup/tor_core.git'
  revision node['tor']['core_revision']

  action :sync
end
