include_attribute 'solrcloud'

node.set['solrcloud']['zk_run'] =  false
node.set['solrcloud']['solr_config']['solrcloud']['zk_host'] = discover_zookeepers("#{node['opsworks_solrcloud']['zookeeper_exhibitor_url']}")
