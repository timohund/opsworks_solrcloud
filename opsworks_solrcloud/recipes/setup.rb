Chef::Log.info("Running opsworks solrcloud setup")
include_recipe 'exhibitor::default'

include_recipe 'runit'
include_recipe 'zookeeper::service'
include_recipe 'exhibitor::service'
