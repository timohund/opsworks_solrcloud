include_attribute 'solrcloud'

node.set['solrcloud']['zk_run'] =  false

default['opsworks_solrcloud']['zookeeper_exibitor_uri'] = "#{node['opsworks']['layers']['solrcloud']['instances']['master']['private_dns_name']}"