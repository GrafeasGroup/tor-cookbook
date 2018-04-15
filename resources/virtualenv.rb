# frozen_string_literal: true
resource_name :virtualenv

property :path, String, name_property: true
property :python, String, default: 'python'

default_action :create

action :create do
  break if ::File.exist?(::File.join(new_resource.path, 'bin', 'activate'))

  py = new_resource.python
  pth = new_resource.path

  execute 'virtualenv create' do
    command "virtualenv --python='#{py}' --no-site-packages '#{pth}'"
  end
end

action :delete do
  break unless ::File.exist?(new_resource.path)

  directory(new_resource.path) do
    action :delete
  end
end
