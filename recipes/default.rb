#
# Cookbook:: tor
# Recipe:: default
#
# Copyright:: 2017, Grafeas Group, Ltd., All Rights Reserved.

include_recipe "#{cookbook_name}::administration"
include_recipe "#{cookbook_name}::redis"
include_recipe "#{cookbook_name}::python"
include_recipe "#{cookbook_name}::app"
