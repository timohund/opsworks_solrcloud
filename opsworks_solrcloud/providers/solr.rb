action :setup do
    sleep 120

    Chef::Log.info("First node is #{node['opsworks']['layers']['solrcloud']['instances'].first}")
    firsthost = node['opsworks']['layers']['solrcloud']['instances'].first[1]

    node.set['opsworks_solrcloud']['is_first_cluster_node'] = firsthost['private_ip'] == node['ipaddress']
    Chef::Log.info("Is this the first node in the cluster?: #{node['opsworks_solrcloud']['is_first_cluster_node']}")

    # Disable the embedded zookeeper in solr
    node.set['solrcloud']['zk_run'] = false

    # during setup no configsets should be imported
    node.set['solrcloud']['manage_zkconfigsets'] = false

    # we want to put the configSets by our own
    node.set['solrcloud']['manage_zkconfigsets_source'] = false

    # during setup no collection should be created
    node.set['solrcloud']['manage_collections'] = false

    Chef::Log.info("First node is #{node['opsworks']['layers']['solrcloud']['instances'].first}")
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

    # we run the solrcloud::tarball recipe here because i needs to run after all other recipes
    # when exhibitor and zookeeper is running
    run_context.include_recipe 'solrcloud::tarball'
end

action :deployconfig do
    if node['opsworks']['layers']['solrcloud']['instances'].first.nil?
        Chef::Log.info("No first instance for layer solrcloud available skipping deployment")
    else
        Chef::Log.info("Starting deployment of solr configuration")

        firsthost = node['opsworks']['layers']['solrcloud']['instances'].first[1]

        node.set['opsworks_solrcloud']['is_first_cluster_node'] = firsthost['private_ip'] == node['ipaddress']
        Chef::Log.info("Is this the first node in the cluster?: #{node['opsworks_solrcloud']['is_first_cluster_node']}")

        # Disable the embedded zookeeper in solr
        node.set['solrcloud']['zk_run'] = false

        # configset updates should only be triggered on the first cluster node
        node.set['solrcloud']['manage_zkconfigsets'] = node['opsworks_solrcloud']['is_first_cluster_node']

        # we want to put the configSets by our own
        node.set['solrcloud']['manage_zkconfigsets_source'] = false

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

        run_context.include_recipe "solrcloud::zkconfigsets"

        run_context.include_recipe "solrcloud::collections"
    end
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