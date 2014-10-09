Chef::Log.info("Running opsworks solrcloud deploy")


# Setup configsets - node['solrcloud']['zkconfigsets']
#include_recipe "solrcloud::zkconfigsets"

# Setup collections - node['solrcloud']['collections']
#include_recipe "solrcloud::collections"