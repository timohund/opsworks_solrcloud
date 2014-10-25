Chef::Log.info("Running opsworks solrcloud deploy in activity #{node['opsworks']['activity']}")

if node['opsworks']['layers']['solrcloud']['instances'].first.nil?
  Chef::Log.info('No first instance for layer solrcloud available skipping deployment')
else
  firsthost = node['opsworks']['layers']['solrcloud']['instances'].first[1]
  # only run on the first cluster node
  if firsthost['private_ip'] == node['ipaddress']
    opsworks_solrcloud_solr 'Downloading solr configuration' do
      action :getconfig
    end

    opsworks_solrcloud_solr 'Deploying solr configuration' do
      action :deployconfig
    end
  else
    Chef::Log.info('Not running on the first node, skipping deployment of solr configuration')
  end
end
