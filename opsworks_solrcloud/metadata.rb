name		"opsworks_solrcloud"
description "Setup solr cloud on aws opsworks"
maintainer 	"AOE"
license 	""
version 	"0.0.1"

depends 	"deploy"
depends		"solrcloud"
depends     "zookeeper"

recipe		"opsworks_solrcloud::configure", "Installs solrcloud as opsworks layer"
recipe		"opsworks_solrcloud::setup", "Setting up solr cloud on opsworks"