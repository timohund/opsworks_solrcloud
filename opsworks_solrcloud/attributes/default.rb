include_attribute 'solrcloud'

node.set['solrcloud']['zk_run'] =  false

default['opsworks_solrcloud']['zookeeper_exibitor_uri'] = 'http://127.0.0.1:8080/'