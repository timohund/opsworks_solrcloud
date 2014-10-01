action :install do
    sleep 60
    if new_resource.use_first_node
      exibitor_uri = new_resource.public_dns_name
    else
      exibitor_uri = new_resource.force_exibitor_uri
    end

    Chef::Log.info("Using #{exibitor_uri} as exibitor_uri")
    hostarray = discover_zookeepers(exibitor_uri)

    if hostarray.nil?
      Chef::Application.fatal!('Failed to discover zookeepers. Cannot continue')
    else


    zk_hosts = ""

    port = hostarray['port']
    servers = hostarray['servers']
    servers_and_ports = []

    servers.each do |server|
        servers_and_ports.push("#{server}:#{port}")
    end

    zk_hosts = servers_and_ports.join(",")

    Chef::Log.info("Using zookeeper hosts string for solr #{zk_hosts}")
    node.override['solrcloud']['solr_config']['solrcloud']['zk_host'] = zk_hosts

    run_context.include_recipe 'solrcloud::tarball'
end

