name 'tor'
maintainer 'Grafeas Group, Ltd.'
maintainer_email 'opensource@thelonelyghost.com'
license 'All Rights Reserved'
description 'Installs/Configures tor'
long_description 'Installs/Configures tor'
version '0.7.0'
chef_version '>= 12.1' if respond_to?(:chef_version)
issues_url 'https://github.com/TranscribersOfReddit/tor-cookbook/issues'
source_url 'https://github.com/TranscribersOfReddit/tor-cookbook'

recipe 'tor::default', 'Install ALL the things!'
recipe 'tor::python', 'Installs/Configures python3, pip, and virtualenv'
recipe 'tor::redis', 'Installs/Configures Redis server'

supports 'centos', '>= 7.3'
depends 'yum-ius', '~> 2.2.0'
depends 'chef-client', '~> 9.0.0'
