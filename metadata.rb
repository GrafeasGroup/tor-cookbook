name 'tor'
maintainer 'Grafeas Group, Ltd.'
maintainer_email 'opensource@thelonelyghost.com'
license 'All Rights Reserved'
description 'Installs/Configures tor'
long_description 'Installs/Configures tor'
version '0.7.1'
chef_version '>= 12.1' if respond_to?(:chef_version)
issues_url 'https://github.com/GrafeasGroup/tor-cookbook/issues'
source_url 'https://github.com/GrafeasGroup/tor-cookbook'

recipe 'tor::default', 'Install ALL the things (in the correct order)'
recipe 'tor::python', 'Installs/Configures python3, pip, and virtualenv'
recipe 'tor::redis', 'Installs/Configures Redis server'
recipe 'tor::app', 'Installs/Configures the ToR bots'

supports 'centos', '>= 7.3'

depends 'yum-ius', '~> 2.2.0'
