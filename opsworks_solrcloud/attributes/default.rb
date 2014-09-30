include_attribute 'solrcloud'

node.set['solrcloud']['zk_run'] =  false

default['opsworks_solrcloud']['zookeeper']['exibitor']['use_first_node'] = true
default['opsworks_solrcloud']['zookeeper']['exibitor']['url'] = 'http://127.0.0.1:8080/'
