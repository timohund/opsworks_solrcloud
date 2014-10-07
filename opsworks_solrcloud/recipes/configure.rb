Chef::Log.info("Running opsworks solrcloud configure")

include_recipe 'exhibitor::default'

include_recipe 'runit'
include_recipe 'zookeeper::service'
include_recipe 'exhibitor::service'

Chef::Log.info("First node is #{node['opsworks']['layers']['solrcloud']['instances'].first}")

firsthost = node['opsworks']['layers']['solrcloud']['instances'].first

opsworks_solrcloud "solr cloud" do
  exhibitor_uri "http://#{firsthost['public_dns_name']}:8080/"
end
