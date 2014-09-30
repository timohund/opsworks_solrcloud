Chef::Log.info("Running opsworks solrcloud configure")

include_recipe 'zookeeper::exhibitor'

if node['opsworks_solrcloud']['zookeeper']['exibitor']['use_first_node']
  exibitor_uri = node['opsworks']['layers']['solrcloud']['instances']['solrcloud2']['public_dns_name']
else
  exibitor_uri = node['opsworks_solrcloud']['zookeeper']['exibitor']['url']
end

Chef::Log.info("Using #{exibitor_uri} as exibitor_uri")

zk_hosts = discover_zookeepers(exibitor_uri)

if zk_nodes.nil?
  Chef::Application.fatal!('Failed to discover zookeepers. Cannot continue')
end

node.override['solrcloud']['solr_config']['solrcloud']['zk_host'] = zk_hosts

include_recipe 'solrcloud::tarball'
