include_attribute 'solrcloud'
node.set['solrcloud']['zk_run'] =  false

#include_attribute 'exhibitor'
#node.override['exhibitor']['install_method'] = 'download'
#node.override['exhibitor']['mirror'] = 'http://central.maven.org/maven2/com/netflix/exhibitor/exhibitor-standalone/1.5.0/exhibitor-standalone-1.5.0.jar'

default['opsworks_solrcloud']['zookeeper']['exibitor']['use_first_node'] = true
default['opsworks_solrcloud']['zookeeper']['exibitor']['url'] = 'http://127.0.0.1:8080/'
