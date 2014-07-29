#
# Cookbook Name:: staticd
# Recipe:: base_server
#
# Copyright (C) 2014 Etienne Garnier
#
# All rights reserved - Do Not Redistribute
#

# Create the main system user for staticd
user node[:staticd][:user] do
  comment "gitreceived system user"
  system true
  shell "/bin/false"
  action :create
end

# Create the main configuration folder for staticd
directory node[:staticd][:config] do
  mode "0755"
end