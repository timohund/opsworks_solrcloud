Chef::Log.info("Running opsworks solrcloud configure")

opsworks_solrcloud_zookeeper "Setting up zookeeper and exhibitor"

opsworks_solrcloud_solr "Getting solr configuration" do
  action :getconfig
end

opsworks_solrcloud_solr "Setting up solr cloud" do
  action :setup
end
