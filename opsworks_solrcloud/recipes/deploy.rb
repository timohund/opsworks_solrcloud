Chef::Log.info("Running opsworks solrcloud deploy")

if node['opsworks']['layers']['solrcloud']['instances'].first.nil?
    Chef::Log.info("No first instance for layer solrcloud available skipping deployment")
else
    opsworks_solrcloud_solr "Deploying solr configuration" do
        action :getconfig
    end

    opsworks_solrcloud_solr "Deploying solr configuration" do
        action :deployconfig
    end
end