Chef::Log.info("Running opsworks solrcloud deploy")

opsworks_solrcloud_discoverzk "discovering zookeeper" do
end

# Setup configsets - node['solrcloud']['zkconfigsets']
include_recipe "solrcloud::zkconfigsets"

# Setup collections - node['solrcloud']['collections']
include_recipe "solrcloud::collections"