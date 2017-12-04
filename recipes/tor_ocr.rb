#
# Cookbook:: tor
# Recipe:: tor_ocr
#
# Copyright:: 2017, Grafeas Group, Ltd., All Rights Reserved.

execute 'install ocr' do
  action :nothing

  cwd '/opt/tor_ocr'

  command <<-EOF.gsub(/^\s+/i, '')
  . /opt/virtualenv/bin/activate && pip install --process-dependency-links .
  EOF
end

git '/opt/tor_ocr' do
  repository 'https://github.com/GrafeasGroup/tor_ocr.git'
  revision node['tor']['ocr_revision']

  # notifies :run, 'execute[install ocr]', :immediately
  action :sync
end
