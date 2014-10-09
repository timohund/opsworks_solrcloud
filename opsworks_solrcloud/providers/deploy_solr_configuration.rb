action :deploy do

    if node['opsworks']['layers']['solrcloud']['instances'].first.nil?
        Chef::Log.info("No first instance for layer solrcloud available skipping deployment")
    else
        Chef::Log.info("Starting deployment of solr configuration")

        firsthost = node['opsworks']['layers']['solrcloud']['instances'].first[1]

        node.set['opsworks_solrcloud']['is_first_cluster_node'] = firsthost['private_ip'] == node['ipaddress']
        Chef::Log.info("Is this the first node in the cluster?: #{node['opsworks_solrcloud']['is_first_cluster_node']}")

        # Disable the embedded zookeeper in solr
        node.set['solrcloud']['zk_run'] = false

        # configset updates should only be triggered on the first cluster node
        node.set['solrcloud']['manage_zkconfigsets'] = node['opsworks_solrcloud']['is_first_cluster_node']

        # we want to put the configSets by our own
        node.set['solrcloud']['manage_zkconfigsets_source'] = false

        # collections should only be managed on the first cluster node
        node.set['solrcloud']['manage_collections'] = node['opsworks_solrcloud']['is_first_cluster_node']

        run_context.include_recipe "solrcloud::zkconfigsets"

        run_context.include_recipe "solrcloud::collections"
    end
end