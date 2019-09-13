# To learn more about Custom Resources, see https://docs.chef.io/custom_resources.html
resource_name :virtualenv

property :path, String, name_property: true
property :python, String, default: 'python'
property :owner, String, default: '1000' # these are insecure defaults, but better than nothing
property :group, String, default: '1000'

default_action :create

action :create do
  py = new_resource.python
  pth = new_resource.path
  owner = new_resource.owner
  group = new_resource.group

  unless ::File.exist?(::File.join(pth, 'bin', 'activate'))
    execute 'virtualenv create' do
      command "#{py} -m venv '#{pth}'"
    end

    execute 'pip upgrade' do
      command ". '#{::File.join(pth, 'bin', 'activate')}'; pip install --upgrade pip"
    end

    # We do this so that we don't need to chown the parent directory and then revert it later
    execute 'chown' do
      command "chown -R '#{owner}:#{group}' '#{pth}'"
    end
  end
end

action :delete do
  break unless ::File.exist?(new_resource.path)

  directory(new_resource.path) do
    action :delete
  end
end
