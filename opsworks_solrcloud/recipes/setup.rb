Chef::Log.info("Running opsworks solrcloud setup")

include_recipe 'exhibitor::default'
include_recipe 'runit'
include_recipe 'zookeeper::service'

directory "/var/lib/zookeeper" do
  group 'zookeeper'
  owner 'zookeeper'
  mode 0775
  recursive true
end

include_recipe 'exhibitor::service'
