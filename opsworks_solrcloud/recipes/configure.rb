Chef::Log.info("Running opsworks solrcloud configure")

opsworks_solrcloud_setattributes "setting attributes"

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

sleep 120

opsworks_solrcloud_discoverzk "discovering zookeeper"

opsworks_solrcloud_setupsolr "solr cloud" do
  exhibitor_uri "http://#{node['opsworks_solrcloud']['exhibitor_url']}/"
end