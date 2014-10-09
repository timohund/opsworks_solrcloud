Chef::Log.info("Running opsworks solrcloud configure")

opsworks_solrcloud_setup_zookeeper "Setting up zookeeper and exhibitor"

sleep 120

opsworks_solrcloud_setup_solr "Setting up solr cloud"
