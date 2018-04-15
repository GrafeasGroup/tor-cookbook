# frozen_string_literal: true
#
# Cookbook:: tor
# Recipe:: app
#
# Copyright:: 2017, Grafeas Group, Ltd., All Rights Reserved.

python3 = shell_out('command -v python3.6').stdout.strip

package 'git' do
  action :install
end

virtualenv '/opt/virtualenv' do
  python python3

  action :create

  not_if { File.exist?('/opt/virtualenv/bin/activate') }
end

user 'tor_bot' do
  comment 'TranscribersOfReddit bots'
  system true
  home '/var/tor'

  action :create
end

group 'bots' do
  members ['tor_bot']
  append true
  action :create
end

directory '/var/tor' do
  owner 'tor_bot'
  group 'bots'
end

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
        version: node['tor'][bot['id'] + '_revision'] || 'master',
      }
    end
  )
end

include_recipe '::tor_core'
include_recipe '::tor_moderator'
include_recipe '::tor_archivist'
include_recipe '::tor_ocr'
