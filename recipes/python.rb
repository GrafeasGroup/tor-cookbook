#
# Cookbook:: tor
# Recipe:: python
#
# Copyright:: 2017, Grafeas Group, Ltd., All Rights Reserved.

python_version = node['tor']['python_version'].gsub(/^v/, '')

# /usr/local/bin/python{MAJOR}.{MINOR} => python3.7
python_exe = "/usr/local/bin/python#{python_version.split('.')[0..1].join('.')}"
python_tgz = ::File.join(Chef::Config[:file_cache_path], 'python.tgz')
pyinstall_dir = ::File.join(Chef::Config[:file_cache_path], 'pyinstall')

remote_file python_tgz do
  source "https://www.python.org/ftp/python/#{python_version}/Python-#{python_version}.tgz"

  action :create
end

directory 'pyinstall' do
  path pyinstall_dir
  recursive true

  action :nothing
end

if platform_family?('rhel')
  package %w(
    gcc gcc-c++ autoconf
    openssl-devel readline-devel sqlite-devel libffi-devel
    libuuid-devel bzip2-devel expat-devel gdbm-devel xz-devel
  )
elsif platform?('ubuntu')
  case node['platform_version']
  when '16.04', '18.04'
    package %w(
      autotools-dev binutils build-essential
      libssl-dev libreadline-dev libsqlite3-dev libffi-dev
      uuid-dev libbz2-dev libexpat1-dev libgdbm-dev lzma-dev
    )
  end
end

execute "tar xzf '#{python_tgz}' --strip-components=1" do
  live_stream true
  creates ::File.join(pyinstall_dir, 'configure')
  cwd pyinstall_dir

  notifies :create, 'directory[pyinstall]', :before
  notifies :delete, 'directory[pyinstall]', :delayed

  not_if { ::File.exist?(python_exe) }
end

execute 'configure python installation' do
  command './configure --enable-optimizations --prefix=/usr/local'
  live_stream true
  creates ::File.join(pyinstall_dir, 'Makefile')
  cwd pyinstall_dir

  not_if { ::File.exist?(python_exe) }
end

execute 'compile python' do
  command 'make'
  live_stream true
  creates ::File.join(pyinstall_dir, 'build')
  cwd pyinstall_dir

  not_if { ::File.exist?(python_exe) }
end

execute 'install python' do
  command lazy {
    if ::File.exist?('/usr/local/bin/python3')
      'make altinstall'
    else
      'make install'
    end
  }

  live_stream true
  creates python_exe
  cwd pyinstall_dir
end

link '/usr/local/bin/python' do
  to '/usr/local/bin/python3'
end

execute 'install pip' do
  command "#{python_exe} -m ensurepip"
  live_stream true

  not_if "#{python_exe} -m pip --version"
end
