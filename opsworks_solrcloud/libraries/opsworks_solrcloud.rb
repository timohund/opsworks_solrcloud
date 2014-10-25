#
# Helper module to retrieve information from the zookeeper
# environment
#

module OpsworksSolrcloud
  # OpsworksSolrcloud Zookeeper Helper
  class Zookeeper
    def self.get_server_array(exhibitor_url)
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

      servers_and_ports
    end
  end
end
