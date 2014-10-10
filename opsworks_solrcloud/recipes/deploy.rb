Chef::Log.info("Running opsworks solrcloud deploy")

opsworks_solrcloud_solr "Deploying solr configuration" do
    action :deployconfig
end

