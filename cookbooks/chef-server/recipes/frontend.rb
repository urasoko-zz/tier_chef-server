package_url = node['chef-server']['url']
package_name = ::File.basename(package_url)
package_local_path = "#{Chef::Config[:file_cache_path]}/#{package_name}"

remote_file package_local_path do
  source package_url
  checksum node['chef-server']['checksum']
end

rpm_package package_name do
  source package_local_path
  notifies :run, 'execute[chef-server-ctl reconfigure]', :immediately
end

node['chef-server']['addons']['packages'].each do |pkg|
  execute "chef-server-ctl install #{pkg}" do
    notifies :run, 'execute[chef-server-ctl reconfigure]', :immediately
  end

  execute "#{pkg}-ctl reconfigure"
end

execute 'chef-server-ctl reconfigure' do
  action :nothing
end
