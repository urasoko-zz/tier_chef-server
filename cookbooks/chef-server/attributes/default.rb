default['chef-server']['url'] = \
  'https://web-dl.packagecloud.io/chef/stable/packages/el/6/'\
  'chef-server-core-12.0.8-1.el6.x86_64.rpm'
default['chef-server']['checksum'] = \
  'ba08e71609c5e794b21e9ebdd9c28c281f1b7ea72af5244c38ef8da76386adc8'
default['chef-server']['addons']['packages'] = \
  %w{opscode-manage opscode-reporting }
