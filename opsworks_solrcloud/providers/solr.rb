action :setup do
  # @todo find another way to wait for running zookeeper before installing solr cloud
  sleep 120

  firsthost = node['opsworks']['layers']['solrcloud']['instances'].first[1]
  exhibitor_url = "http://#{firsthost['private_dns_name']}:8080/"
  Chef::Log.info("Exhibitor node is #{exhibitor_url}")

  servers_and_ports = OpsworksSolrcloud::Zookeeper.get_server_array(exhibitor_url)
  Chef::Log.info("Using zookeeper hosts string for solr #{servers_and_ports}")

  node.override['solrcloud']['solr_config']['solrcloud']['zk_host'] = servers_and_ports

  run_context.include_recipe 'opsworks_solrcloud::solrcloud_install'
  new_resource.updated_by_last_action(true)
end

action :deployconfig do
  firsthost = node['opsworks']['layers']['solrcloud']['instances'].first[1]
  exhibitor_url = "http://#{firsthost['private_dns_name']}:8080/"
  Chef::Log.info("Exhibitor node is #{exhibitor_url}")

  servers_and_ports = OpsworksSolrcloud::Zookeeper.get_server_array(exhibitor_url)
  Chef::Log.info("Using zookeeper hosts string for solr #{servers_and_ports}")

  node.override['solrcloud']['solr_config']['solrcloud']['zk_host'] = servers_and_ports

  Chef::Log.info('Starting deployment of solr configuration')
  Chef::Log.info("Using jetty context #{node['solrcloud']['jetty_config']['context']['path']}")
  Chef::Log.info("Using solr core admin path #{node['solrcloud']['solr_config']['admin_path']}")

  run_context.include_recipe 'opsworks_solrcloud::solrcloud_deployconfig'

  new_resource.updated_by_last_action(true)
end

action :getconfig do
  run_context.include_recipe 'aws'
  Chef::Log.info('Getting solr configuration from s3 bucket')

  zkconfigtar_tmp = '/tmp/zkconfigtar/'

  directory zkconfigtar_tmp do
    recursive true
    action :delete
  end

  directory zkconfigtar_tmp do
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end

  aws_s3_file "#{zkconfigtar_tmp}solrconfig.tar.gz" do
    bucket new_resource.zkconfigsets_s3_bucket
    remote_path new_resource.zkconfigsets_s3_remote_path
    aws_access_key_id new_resource.zkconfigsets_s3_aws_access_key_id
    aws_secret_access_key new_resource.zkconfigsets_s3_aws_secret_access_key
  end

  bash 'zkconfigtar' do
    cwd zkconfigtar_tmp
    code <<-EOF
         tar xvfz solrconfig.tar.gz
         rm solrconfig.tar.gz
         cp -R * #{node['solrcloud']['zkconfigsets_home']}
    EOF
  end

  new_resource.updated_by_last_action(true)
end

action :restart do
  service 'solr' do
    action :restart
  end

  new_resource.updated_by_last_action(true)
end
