#
# Cookbook Name:: staticd
# Recipe:: default
#
# Copyright (C) 2014 Etienne Garnier
#
# All rights reserved - Do Not Redistribute
#

include_recipe "staticd::base_server"
include_recipe "staticd::web_server"
include_recipe "staticd::deployment_server"
