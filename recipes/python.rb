#
# Cookbook:: tor
# Recipe:: python
#
# Copyright:: 2017, Grafeas Group, Ltd., All Rights Reserved.

include_recipe 'yum-ius::default'

yum_package %w[python34 python34-devel] do
  action :install
end

remote_file '/tmp/get-pip.py' do
  source 'https://bootstrap.pypa.io/get-pip.py'

  action :create
end

execute 'python3 /tmp/get-pip.py' do
  action :run

  not_if 'python3 -m pip --version'
end

yum_package %w[python36u python36u-pip python36u-devel] do
  action :install
end

execute 'python3.6 -m pip install virtualenv' do
  action :run

  not_if 'command -v virtualenv'
end
