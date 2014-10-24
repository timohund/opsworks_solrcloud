default['opsworks_solrcloud']['zkconfigsets']['source'] = 's3'
default['opsworks_solrcloud']['zkconfigsets']['s3']['bucket'] = 'mybucket'
default['opsworks_solrcloud']['zkconfigsets']['s3']['remote_path'] = 'mybucket_path'
default['opsworks_solrcloud']['zkconfigsets']['s3']['aws_access_key_id'] = 'mybucket_access_key_id'
default['opsworks_solrcloud']['zkconfigsets']['s3']['aws_secret_access_key'] = 'myaccess_secet_access_key'

include_attribute 'solrcloud'
node.set['solrcloud']['jetty_config']['context']['path'] = '/'
node.set['solrcloud']['solr_config']['admin_path'] = '/admin'