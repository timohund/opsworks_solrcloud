actions :setup, :deployconfig, :getconfig, :restart
default_action :setup

attribute :zkconfigsets_source, :kind_of => String, :default => node['opsworks_solrcloud']['zkconfigsets']['source']
attribute :zkconfigsets_s3_bucket, :kind_of => String, :default => node['opsworks_solrcloud']['zkconfigsets']['s3']['bucket']
attribute :zkconfigsets_s3_remote_path, :kind_of => String, :default => node['opsworks_solrcloud']['zkconfigsets']['s3']['remote_path']
attribute :zkconfigsets_s3_aws_access_key_id, :kind_of => String, :default => node['opsworks_solrcloud']['zkconfigsets']['s3']['aws_access_key_id']
attribute :zkconfigsets_s3_aws_secret_access_key, :kind_of => String, :default => node['opsworks_solrcloud']['zkconfigsets']['s3']['aws_secret_access_key']
