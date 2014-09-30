include_attribute 'solrcloud'

node.set['solrcloud']['zk_run'] =  false

include_attribute 'zookeeper'

node.set['zookeeper']['version'] = "3.4.6"

default['opsworks_solrcloud']['zookeeper']['exibitor']['use_first_node'] = true
default['opsworks_solrcloud']['zookeeper']['exibitor']['url'] = 'http://127.0.0.1:8080/'
