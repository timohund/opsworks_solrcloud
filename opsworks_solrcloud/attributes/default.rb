include_attribute 'solrcloud'
node.set['solrcloud']['zk_run'] =  false

include_attribute 'java'
node.set['java']['jdk_version'] = '7'

include_attribute 'zookeeper'
node.set['zookeeper']['service_style'] =  'exhibitor'

servers = []
instances = node['opsworks']['layers']['solrcloud']['instances']
instances.each_with_index do |instance, index|
    private_ip = instance[1]['private_ip']
    hostindex = index + 1
    servers.push("#{hostindex}:#{private_ip}")
end

server_specs = servers.join(",");

Chef::Log.info("Using #{server_specs} as exhibitor server_specs")

include_attribute 'exhibitor'
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
  zoo_cfg_extra: 'tickTime\=2000&initLimit\=10&syncLimit\=5',
  auto_manage_instances_settling_period_ms: '0',
  auto_manage_instances: '1',
  servers_spec: "#{server_specs}"
}