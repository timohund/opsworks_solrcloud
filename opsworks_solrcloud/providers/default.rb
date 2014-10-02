action :install do
    sleep 60

    exhibitor_uri = new_resource.exhibitor_uri

    Chef::Log.info("Using #{exhibitor_uri} as exhibitor_uri")

    hostarray = discover_zookeepers(exhibitor_uri)
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

    run_context.include_recipe 'solrcloud::tarball'
end

