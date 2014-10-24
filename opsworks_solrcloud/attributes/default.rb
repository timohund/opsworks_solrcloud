default['opsworks_solrcloud']['zkconfigsets']['source'] = 's3'
default['opsworks_solrcloud']['zkconfigsets']['s3']['bucket'] = 'mybucket'
default['opsworks_solrcloud']['zkconfigsets']['s3']['remote_path'] = 'mybucket_path'
default['opsworks_solrcloud']['zkconfigsets']['s3']['aws_access_key_id'] = 'mybucket_access_key_id'
default['opsworks_solrcloud']['zkconfigsets']['s3']['aws_secret_access_key'] = 'myaccess_secet_access_key'

include_attribute 'solrcloud'
node.set['solrcloud']['jetty_config']['context']['path'] = '/'
node.set['solrcloud']['solr_config']['admin_path'] = '/admin'
node.set['solrcloud']['solr_config']['solrcloud']['host_context'] = '/'

# we use zookeeper provided by zookeeper and exhibitor cookbook
node.set['solrcloud']['zk_run'] = false

# allow larger config files in zookeeper
node.set['solrcloud']['java_options'] = (node['solrcloud']['java_options'] || []) + [" -Djute.maxbuffer=50000000 "]

# we want to put the configSets by our own
node.set['solrcloud']['manage_zkconfigsets_source'] = false
node.set['solrcloud']['manage_zkconfigsets']        = false
node.set['solrcloud']['force_zkconfigsets_upload']  = false
node.set['solrcloud']['manage_collections']         = false

# on the first cluster node we manage collections and config sets
if node['opsworks']['layers']['solrcloud']['instances'].first.nil?
  firsthost = node['opsworks']['layers']['solrcloud']['instances'].first[1]
  is_first_cluster_node = firsthost['private_ip'] == node['ipaddress']

  if is_first_cluster_node?
    node.set['solrcloud']['manage_zkconfigsets']        = true
    node.set['solrcloud']['force_zkconfigsets_upload']  = true
    node.set['solrcloud']['manage_collections']         = true
  end
end