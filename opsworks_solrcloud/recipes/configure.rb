Chef::Log.info("Running opsworks solrcloud configure")
Chef::Log.info("Using #{node['opsworks_solrcloud']['zookeeper_exibitor_uri']} as zookeeper exibitor")

zk_hosts = discover_zookeepers("#{node['opsworks_solrcloud']['zookeeper_exibitor_uri']}")
if zk_nodes.nil?
  Chef::Application.fatal!('Failed to discover zookeepers. Cannot continue')
end

node.override['solrcloud']['solr_config']['solrcloud']['zk_host'] = zk_hosts

include_recipe 'zookeeper::install'
include_recipe 'solrcloud::tarball'
