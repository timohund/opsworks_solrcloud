include_attribute 'solrcloud'
node.set['solrcloud']['zk_run'] =  false

include_attribute 'java'
node.set['java']['jdk_version'] = '7'

include_attribute 'zookeeper'
node.set['zookeeper']['service_style'] =  'exhibitor'
