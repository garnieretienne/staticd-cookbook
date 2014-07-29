# Port used to receive GIT pushes through SSH
default[:staticd][:git_port] = "2288"

# Port used to serve website through HTTP
default[:staticd][:http_port] = "8080"

# Main configuration folder
default[:staticd][:config] = "/etc/staticd"

# Root folder for websites configurations
default[:staticd][:sites] = "#{node[:staticd][:config]}/sites"

# Root folder where final websites ready to be served are stored
default[:staticd][:www] = "/srv/www"

# Directory used by gitreceived to cache git repository
default[:staticd][:git_cache] = "/var/cache/gitreceived"

# Main certificate used by the SSH deamon of gitreceived
default[:staticd][:git_cert] = "#{node[:staticd][:config]}/key.pem"

# Script used by gitreceived to authenticate and permit GIT pushes
default[:staticd][:authchecker] = "/usr/local/bin/authenticate"

# Root folder used by the "authenticate" script containing users public keys
default[:staticd][:allowed_keys] = "#{node[:staticd][:config]}/allowed_keys.d"

# Script used by gitreceived to package and deploy incomming websites source
default[:staticd][:receiver] = "/usr/local/bin/deploy"

# Cache dir used by the "deploy" script
default[:staticd][:build_cache] = "/tmp/build"

# Script used to generate website configuration after each deployement
default[:staticd][:router] = "/usr/local/bin/httproute"

# Main system user used by staticd utilities
default[:staticd][:user] = "staticd"
