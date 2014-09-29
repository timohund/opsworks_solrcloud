Chef::Log.info("Running opsworks solrcloud setup")

include_recipe 'zookeeper::install'
include_recipe 'solrcloud::tarball'
