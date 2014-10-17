action :setup do

  #
  # Use version 7 of java
  #
  node.set['java']['jdk_version'] = '7'

  #
  # Manage zookeeper control with exhibitor
  #
  node.set['zookeeper']['service_style'] = 'exhibitor'

  #
  # Set the install dir
  #
  node.set['zookeeper']['install_dir'] = '/usr/local/zookeeper'


  #
  # Configure exibitor to use all cluster nodes a zookeeper instance nodes
  #
  servers = []
  instances = node['opsworks']['layers']['solrcloud']['instances']
  instances.each_with_index do |instance, index|
    private_ip = instance[1]['private_ip']
    hostindex = index + 1
    servers.push("#{hostindex}:#{private_ip}")
  end

  server_specs = servers.join(",");

  Chef::Log.info("Using #{server_specs} as exhibitor server_specs")

  node.set['exhibitor']['snapshot_dir'] = '/opt/zookeeper/data/snapshots/'
  node.set['exhibitor']['transaction_dir'] = '/opt/zookeeper/data/transactions'
  node.set['exhibitor']['log_index_dir'] = '/opt/zookeeper/data/logindex'
  node.set['exhibitor']['install_dir'] = '/usr/local/exhibitor'

  node.set['exhibitor']['cli'] = {
     port: '8080',
     hostname: node[:ipaddress],
     configtype: 'file',
     defaultconfig: "#{node[:exhibitor][:install_dir]}/exhibitor.properties"
  }

  node.set['exhibitor']['config'] = {
      cleanup_period_ms: 5 * 60 * 1000,
      check_ms: '30000',
      backup_period_ms: '0',
      client_port: '2181',
      cleanup_max_files: '20',
      backup_max_store_ms: '0',
      connect_port: '2888',
      backup_extra: '',
      observer_threshold: '0',
      election_port: '3888',
      zoo_cfg_extra: 'tickTime\=3000&initLimit\=30&syncLimit\=30',
      auto_manage_instances_settling_period_ms: '0',
      auto_manage_instances: '1',
      servers_spec: "#{server_specs}",
      java_environment: 'JVMFLAGS\=" $JVMFLAGS -Djute.maxbuffer\=50000000" '
  }

  run_context.include_recipe 'exhibitor::default'
  run_context.include_recipe 'runit'
  run_context.include_recipe 'zookeeper::service'

  directory "/var/lib/zookeeper" do
    group 'zookeeper'
    owner 'zookeeper'
    mode 0775
    recursive true
  end

  run_context.include_recipe 'exhibitor::service'
end