#
# Cookbook:: tor
# Recipe:: app
#
# Copyright:: 2017, Grafeas Group, Ltd., All Rights Reserved.

python3 = `command -v python3.6`.strip

package 'git' do
  action :install
end

virtualenv '/opt/virtualenv' do
  python python3

  action :create
  not_if { File.exist?('/opt/virtualenv/bin/activate') }
end

execute 'install tor' do
  action :nothing

  cwd '/opt/tor'

  command <<-EOF
  . /opt/virtualenv/bin/activate && pip install --process-dependency-links .
  EOF
end

execute 'install archivist' do
  action :nothing

  cwd '/opt/tor_archivist'

  command <<-EOF
  . /opt/virtualenv/bin/activate && pip install --process-dependency-links .
  EOF
end

execute 'install ocr' do
  action :nothing

  cwd '/opt/tor_ocr'

  command <<-EOF.gsub(/^\s+/i, '')
  . /opt/virtualenv/bin/activate && pip install --process-dependency-links .
  EOF
end

git '/opt/tor' do
  repository 'https://github.com/GrafeasGroup/tor.git'
  revision node['tor']['tor_revision']

  notifies :run, 'execute[install tor]', :immediately
  action :sync
end

git '/opt/tor_archivist' do
  repository 'https://github.com/GrafeasGroup/tor_archivist.git'
  revision node['tor']['archivist_revision']

  notifies :run, 'execute[install archivist]', :immediately
  action :sync
end

git '/opt/tor_ocr' do
  repository 'https://github.com/GrafeasGroup/tor_ocr.git'
  revision node['tor']['ocr_revision']

  # notifies :run, 'execute[install ocr]', :immediately
  action :sync
end

directory '/var/tor'

template '/var/tor/praw.ini' do
  source 'praw.ini.erb'

  variables(
    bots: (search(:bots, '*:*') || []).map do |bot|
      {
        slug: bot['slug'],
        username: bot['username'],
        password: bot['password'],
        client_id: bot['client_id'],
        secret: bot['secret_key'],
        user_agent_slug: bot['user_agent_slug'] || bot['username'],
        version: node['tor'][bot['slug'] + '_revision'] || 'master'
      }
    end
  )
end
