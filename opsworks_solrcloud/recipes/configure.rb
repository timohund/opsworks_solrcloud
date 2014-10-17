Chef::Log.info("Running opsworks solrcloud configure")

opsworks_solrcloud_zookeeper "Setting up zookeeper and exhibitor" do
   action [ :setup, :restart ]
end

opsworks_solrcloud_solr "Setting up solr cloud" do
  action :setup
end
