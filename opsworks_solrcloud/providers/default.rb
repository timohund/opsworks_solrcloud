action :install do
    if new_resource.use_first_node
      exibitor_uri = new_resource.public_dns_name
    else
      exibitor_uri = new_resource.force_exibitor_uri
    end

    Chef::Log.info("Using #{exibitor_uri} as exibitor_uri")

    zk_hosts = discover_zookeepers(exibitor_uri)

    if zk_hosts.nil?
      Chef::Application.fatal!('Failed to discover zookeepers. Cannot continue')
    end

    node.override['solrcloud']['solr_config']['solrcloud']['zk_host'] = zk_hosts

    include_recipe 'solrcloud::tarball'
end

