Chef::Log.info("Running opsworks solrcloud configure")

include_recipe 'exhibitor::default'

include_recipe 'zookeeper::service'
include_recipe 'exhibitor::service'

opsworks_solrcloud "solr cloud" do
  public_dns_name "http://#{node['opsworks']['layers']['solrcloud']['instances']['solrcloud1']['public_dns_name']}:8080/"
  force_exibitor_uri node['opsworks_solrcloud']['zookeeper']['exibitor']['url']
  use_first_node node['opsworks_solrcloud']['zookeeper']['exibitor']['use_first_node']
end
