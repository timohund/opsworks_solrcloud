action :setup do
  #@todo find another way to wait for running zookeeper before installing solr cloud
  sleep 120

  Chef::Log.info("First node is #{node['opsworks']['layers']['solrcloud']['instances'].first}")
  firsthost = node['opsworks']['layers']['solrcloud']['instances'].first[1]

  node.set['opsworks_solrcloud']['is_first_cluster_node'] = firsthost['private_ip'] == node['ipaddress']
  Chef::Log.info("Is this the first node in the cluster?: #{node['opsworks_solrcloud']['is_first_cluster_node']}")

  # during setup no configsets should be imported
  node.set['solrcloud']['manage_zkconfigsets'] = node['opsworks_solrcloud']['is_first_cluster_node']

  # force the upload from the first node
  node.set['solrcloud']['force_zkconfigsets_upload'] = node['opsworks_solrcloud']['is_first_cluster_node']

  # during setup no collection should be created
  node.set['solrcloud']['manage_collections'] = node['opsworks_solrcloud']['is_first_cluster_node']


  # we increase the max buffer size to allow nodes in zookeeper larger then one megabyte
  node.set['solrcloud']['java_options'] = (node['solrcloud']['java_options'] || []) + [" -Djute.maxbuffer=50000000 "]
  Chef::Log.info("JVM options #{node['solrcloud']['java_options']}")

  exhibitor_url = "http://#{firsthost['private_dns_name']}:8080/"
  Chef::Log.info("Exhibitor node is #{exhibitor_url}")

  hostarray = discover_zookeepers(exhibitor_url)
  if hostarray.nil?
    Chef::Application.fatal!('Failed to discover zookeepers. Cannot continue')
  end

  port = hostarray['port']
  servers = hostarray['servers']
  servers_and_ports = []

  servers.each do |server|
    servers_and_ports.push("#{server}:#{port}")
  end

  Chef::Log.info("Using zookeeper hosts string for solr #{servers_and_ports}")
  node.override['solrcloud']['solr_config']['solrcloud']['zk_host'] = servers_and_ports

  # when exhibitor and zookeeper is running
  run_context.include_recipe "opsworks_solrcloud::solrcloud_install"
end

action :deployconfig do
  Chef::Log.info("Starting deployment of solr configuration")

  firsthost = node['opsworks']['layers']['solrcloud']['instances'].first[1]

  node.set['opsworks_solrcloud']['is_first_cluster_node'] = firsthost['private_ip'] == node['ipaddress']
  Chef::Log.info("Is this the first node in the cluster?: #{node['opsworks_solrcloud']['is_first_cluster_node']}")

  # configset updates should only be triggered on the first cluster node
  node.set['solrcloud']['manage_zkconfigsets'] = node['opsworks_solrcloud']['is_first_cluster_node']

  # force the upload from the first node
  node.set['solrcloud']['force_zkconfigsets_upload'] = node['opsworks_solrcloud']['is_first_cluster_node']

  # collections should only be managed on the first cluster node
  node.set['solrcloud']['manage_collections'] = node['opsworks_solrcloud']['is_first_cluster_node']

  exhibitor_url = "http://#{firsthost['private_dns_name']}:8080/"
  Chef::Log.info("Exhibitor node is #{exhibitor_url}")

  hostarray = discover_zookeepers(exhibitor_url)
  if hostarray.nil?
    Chef::Application.fatal!('Failed to discover zookeepers. Cannot continue')
  end

  port = hostarray['port']
  servers = hostarray['servers']
  servers_and_ports = []

  servers.each do |server|
    servers_and_ports.push("#{server}:#{port}")
  end

  Chef::Log.info("Using zookeeper hosts string for solr #{servers_and_ports}")
  node.override['solrcloud']['solr_config']['solrcloud']['zk_host'] = servers_and_ports

  Chef::Log.info("Using jetty context #{node['solrcloud']['jetty_config']['context']['path']}")
  Chef::Log.info("Using solr core admin path #{node['solrcloud']['solr_config']['admin_path']}")

  run_context.include_recipe "opsworks_solrcloud::solrcloud_deployconfig"
end

action :getconfig do
  run_context.include_recipe 'aws'
  Chef::Log.info("Getting solr configuration from s3 bucket")

  zkconfigtar_tmp = "/tmp/zkconfigtar/"

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

  bash "zkconfigtar" do
    cwd zkconfigtar_tmp
    code <<-EOF
         tar xvfz solrconfig.tar.gz
         rm solrconfig.tar.gz
         cp -R * #{node['solrcloud']['zkconfigsets_home']}
    EOF
  end
end

action :restart do
  service "solr" do
    action :restart
  end
end