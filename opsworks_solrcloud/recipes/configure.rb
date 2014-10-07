Chef::Log.info("First node is #{node['opsworks']['layers']['solrcloud']['instances'].first}")

firsthost = node['opsworks']['layers']['solrcloud']['instances'].first.last

Chef::Log.info("First node is #{firsthost['private_dns_name']}")

opsworks_solrcloud "solr cloud" do
  exhibitor_uri "http://#{firsthost['private_dns_name']}:8080/"
end