#
# Cookbook Name:: staticd
# Recipe:: web_server
#
# Copyright (C) 2014 Etienne Garnier
#
# All rights reserved - Do Not Redistribute
#

# Install the filesystem monitoring tool needed to monitor
# changes on web service configuration
package "inotify-tools" do
  action :install
end

# Create the root folder for websites sources
directory node[:staticd][:www] do
  owner node[:staticd][:user]
  group node[:staticd][:user]
  mode "0755"
end

# Create the root folder for websites configuration
directory node[:staticd][:sites] do
  recursive true
  user node[:staticd][:user]
  group node[:staticd][:user]
  mode "0755"
end

# Deploy the router utility
template "/usr/local/bin/httproute" do
  source "httproute.erb"
  mode "0755"
end

# Deploy the deamon monitoring the web service configuration
template "/usr/local/bin/httprouted" do
  source "httprouted.erb"
  mode "0755"
end

# Configure upstart to manage the deamon monitoring the web
# service configuration
template "/etc/init/httprouted.conf" do
  source "httprouted.conf.erb"
end

# Ensure the deamon monitoring the web service configuration
# is running
service "httprouted" do
  provider Chef::Provider::Service::Upstart
  action :start
end

# Install the NGINX web server
include_recipe "nginx"

# Add a vhost folder to NGINX dedicated to staticd hosting
template "/etc/nginx/conf.d/staticd.conf" do
  source "staticd.conf.erb"
end
