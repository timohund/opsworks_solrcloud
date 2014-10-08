
include_recipe 'exhibitor::default'
include_recipe 'runit'
include_recipe 'zookeeper::service'

directory "/var/lib/zookeeper" do
  group 'zookeeper'
  owner 'zookeeper'
  mode 0775
  recursive true
end

include_recipe 'exhibitor::service'

Chef::Log.info("First node is #{node['opsworks']['layers']['solrcloud']['instances'].first}")

firsthost = node['opsworks']['layers']['solrcloud']['instances'].first[1]

Chef::Log.info("First node is #{firsthost['private_dns_name']}")

opsworks_solrcloud_setupsolr "solr cloud" do
  exhibitor_uri "http://#{firsthost['private_dns_name']}:8080/"
end