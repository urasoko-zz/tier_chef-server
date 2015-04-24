require 'chef/provisioning'
require 'chef/provisioning/ssh_driver'

with_driver 'ssh'

backend_fqdn = 'backend.cl-lab.io'    #entry your backend server info
backend_ipaddr = '10.132.7.113'       #entry your backend server info
frontend_fqdn = 'frontend.cl-lab.io'  #entry your frontend server info
frontend_ipaddr = '10.132.7.114'      #entry your frontend server info

backend_files = %w{chef-server-running.json chef-server.rb
  dark_launch_features.json logrotate.conf pivotal.pem pivotal.rb
  private-chef-secrets.json private-chef.sh webui_priv.pem webui_pub.pem
  worker-private.pem worker-public.pem}

reporting_files = %w{opscode-reporting-running.json
  opscode-reporting-secrets.json pedant_config.rb}

machine "backend" do
  machine_options :transport_options => {
    :ip_address => backend_ipaddr,
    :username => 'root',
    :ssh_options => {
      :keys => ['~/.ssh/id_rsa']      #custom to your auth info
    }
  }
  attribute %w[chef-server backend fqdn], backend_fqdn
  attribute %w[chef-server backend ipaddr], backend_ipaddr
  attribute %w[chef-server frontend fqdn], frontend_fqdn
  attribute %w[chef-server frontend ipaddr], frontend_ipaddr
  recipe 'chef-server::backend'
  converge true
end

backend_files.each do |file|
  machine_file "/etc/opscode/#{file}" do
    local_path "/tmp/#{file}"
    machine 'backend'
    action :download
  end
end

reporting_files.each do |file|
  machine_file "/etc/opscode-reporting/#{file}" do
    local_path "/tmp/#{file}"
    machine 'backend'
    action :download
  end
end

machine "frontend" do
  machine_options :transport_options => {
    :ip_address => frontend_ipaddr,
    :username => 'root',
    :ssh_options => {
      :keys => ['~/.ssh/id_rsa']      #custom to your auth info
    }
  }
  action :allocate
end

backend_files.each do |file|
  machine_file "/etc/opscode/#{file}" do
    local_path "/tmp/#{file}"
    machine 'frontend'
    action :upload
  end
end

reporting_files.each do |file|
  machine_file "/etc/opscode-reporting/#{file}" do
    local_path "/tmp/#{file}"
    machine 'frontend'
    action :upload
  end
end

machine "frontend" do
  recipe 'chef-server::frontend'
  converge true
end
