package_url = node['chef-server']['url']
package_name = ::File.basename(package_url)
package_local_path = "#{Chef::Config[:file_cache_path]}/#{package_name}"

remote_file package_local_path do
  source package_url
  checksum node['chef-server']['checksum']
end

directory '/etc/opscode'

template '/etc/opscode/chef-server.rb' do
  source 'chef-server.rb.erb'
end

rpm_package package_name do
  source package_local_path
  notifies :run, 'execute[chef-server-ctl reconfigure]', :immediately
end

execute "chef-server-ctl install opscode-reporting" do
  notifies :run, 'execute[chef-server-ctl reconfigure]', :immediately
end

execute "opscode-reporting-ctl reconfigure"

execute 'chef-server-ctl reconfigure' do
  action :nothing
end
