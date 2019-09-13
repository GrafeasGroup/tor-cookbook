#
# Cookbook:: tor
# Recipe:: app
#
# Copyright:: 2017, Grafeas Group, Ltd., All Rights Reserved.

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

include_recipe 'tor::tor_moderator'
include_recipe 'tor::tor_archivist'
include_recipe 'tor::tor_ocr'
