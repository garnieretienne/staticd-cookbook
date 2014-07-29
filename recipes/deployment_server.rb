#
# Cookbook Name:: staticd
# Recipe:: deployment_server
#
# Copyright (C) 2014 Etienne Garnier
#
# All rights reserved - Do Not Redistribute
#

# Create the cache dir used by the 'deploy' script
directory node[:staticd][:build_cache] do
  owner node[:staticd][:user]
  group node[:staticd][:user]
  mode "0755"
end

# Create the cache dir used by gitreceived to cache git repository
directory node[:staticd][:git_cache] do
  owner node[:staticd][:user]
  group node[:staticd][:user]
  mode "0755"
end

# Create the root dir used by the "authenticate" script to verify user identity
directory node[:staticd][:allowed_keys] do
  mode "0755"
end

# Deploy the 'deploy' utility
template "/usr/local/bin/deploy" do
  source "deploy.erb"
  mode "0755"
end

# Deploy the 'authenticate' utility
template "/usr/local/bin/authenticate" do
  source "authenticate.erb"
  mode "0755"
end

# Gitreceived is build from source using these constants
GITRECEIVED_VERSION="d828619bceb1937a5daad1dceea6320e9d3b3d4f"
GITRECEIVED_SRC_URL="https://github.com/flynn/gitreceived/archive/#{GITRECEIVED_VERSION}.zip"
GITRECEIVED_SRC_PATH="/usr/local/src/gitreceived-#{GITRECEIVED_VERSION}"
GITRECEIVED_DEPENDENCIES=%w(unzip golang git mercurial openssl)

# Install dependencies used to build gitreceived from source
GITRECEIVED_DEPENDENCIES.each do |package_name|
  package package_name do
    action :nothing
  end
end

# Move the gitreceived utility into the system PATH
bash "install_gitreceived" do
  cwd GITRECEIVED_SRC_PATH
  code <<-EOF
    mv gitreceived /usr/local/bin/
  EOF
  action :nothing
end

# Build the gitreceived utility
bash "compile_gitreceived_source" do
  cwd GITRECEIVED_SRC_PATH
  code <<-EOF
    rm --force gitreceived
    rm --force --recursive workspace
    mkdir workspace

    # Godep installation failed randomly due to some random SSL errors and/or
    # mercurial errors.
    # Using this ugly fix until proper way to install it or fixing it is found.
    counter=0
    try=10
    while ! GOPATH=#{GITRECEIVED_SRC_PATH}/workspace go get github.com/tools/godep; do
      counter=$((counter+1))
      if [ "$counter" -ge "$try" ]; then
        echo "'go get github.com/tools/godep' failed ${try} times, exiting..." 1>&2
        exit 1
      else
        echo "'go get github.com/tools/godep' failed, retrying..."
      fi
    done


    PATH=$PATH:#{GITRECEIVED_SRC_PATH}/workspace/bin godep go build gitreceived.go
  EOF
  notifies :run, "bash[install_gitreceived]", :immediately
  action :nothing
end

# Extract sources of gitreceived to the correct source path and remove the downloaded archive
bash "extract_gitreceived_source" do
  cwd Chef::Config['file_cache_path']
  code <<-EOF
    rm --recursive --force #{GITRECEIVED_SRC_PATH}
    mkdir #{GITRECEIVED_SRC_PATH}
    unzip gitreceived-#{GITRECEIVED_VERSION}.zip -d #{GITRECEIVED_SRC_PATH}
    mv #{GITRECEIVED_SRC_PATH}/*/* #{GITRECEIVED_SRC_PATH}/
    rm --force "#{Chef::Config['file_cache_path']}/gitreceived-#{GITRECEIVED_VERSION}.zip"
  EOF
  notifies :run, "bash[compile_gitreceived_source]", :immediately
  action :nothing
end

# Download source of gitreceived if the utility it not present on the system
remote_file "#{Chef::Config['file_cache_path']}/gitreceived-#{GITRECEIVED_VERSION}.zip" do
  source "https://github.com/flynn/gitreceived/archive/#{GITRECEIVED_VERSION}.zip"
  GITRECEIVED_DEPENDENCIES.each do |package_name|
    notifies :install, "package[#{package_name}]", :immediately
  end
  notifies :run, "bash[extract_gitreceived_source]", :immediately
  not_if "which gitreceived"
end

# Configure upstart to manage gitreceived
template "/etc/init/gitreceived.conf" do
  source "gitreceived.conf.erb"
end

# Generate the main certificate used by the SSH deamon of gitreceived
bash "generate_a_pem_certificat_for_gitreceived" do
  code <<-EOF
    mkdir --parent $(dirname #{node[:staticd][:git_cert]})
    openssl genrsa -out #{node[:staticd][:git_cert]} 1024
    chmod 400 #{node[:staticd][:git_cert]}
    chown #{node[:staticd][:user]}:#{node[:staticd][:user]} \
      #{node[:staticd][:git_cert]}
  EOF
  not_if "ls #{node[:staticd][:git_cert]}"
end

# Ensure gitreceived is running
service "gitreceived" do
  provider Chef::Provider::Service::Upstart
  action :start
  subscribes :restart, "template[/etc/init/gitreceived.conf]", :delayed
end
