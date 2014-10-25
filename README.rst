++++++++++++++++++++++++
Solr cloud cookbook for AWS OpsWorks
++++++++++++++++++++++++

:Author: AOE <dev@aoe.com>
:Author: Timo Schmidt
:Author: Nikolay Diaur
:Author: Michael Klapper
:Description: Cookbook to install solrcloud on an aws opsworks stack
:Build status: |buildStatusIcon|

Foreword
========================

This cookbook can be used to install SolrCloud on an aws OpsWorks stack.

It uses the solrcloud cookbooks to install solr in a cloud mode with an external zookeeper service.
By now we install zookeeper on each node and use exhibitor to discover the zookeeper instances
with our chef cookbook

What do i need to configure?
========================

You need to:

1. Create a new stack with the name "solrcloud"

    * Enable "Manage Berkshelf" (to enable the evaluation of Berksfile)
    * Use Berkshelf version 3.1.3
    * Add custom stack json configuration:

::

    {
        "opsworks_solrcloud":
        {
            "zkconfigsets":
            {
                "source": "s3",
                "s3":
                {
                    "bucket": "#configset_bucket#",
                    "remote_path": "#configset_tarball##",
                    "aws_access_key_id": "#access_key_id#",
                    "aws_secret_access_key": "#access_secret#"
                }
            }
        },
        "solrcloud":
        {
            "zkconfigsets":
            {
                "#configsetname#":
                {
                    "action": "create"
                }
            },
            "collections":
            {
                "#collectionname#":
                {
                    "collection_config_name": "#configsetname#"
                    "name": "#collectionname#"
                }
            }
        }
    }
::

With the configuration above you will get a tarball from an s3 bucket, that needs to contain the solr configuration
for each configset. The "zkconfigsets" and "collections" configuration is used by the solrcloud cookbook
to upload the configuration to zookeeper.

Example:

::

    {
        "opsworks_solrcloud":
        {
            "zkconfigsets":
            {
                "source": "s3",
                "s3":
                {
                    "bucket": "myreleasebucket",
                    "remote_path": "/solr/config.tar.hz",
                    "aws_access_key_id": "key",
                    "aws_secret_access_key": "accesskey"
                }
            }
        },
        "solrcloud":
        {
            "zkconfigsets":
            {
                "exampleconfig":
                {
                    "action": "create"
                }
            },
            "collections":
            {
                "example":
                {
                    "collection_config_name": "exampleconfig"
                }
            }
        }
    }
::


The tar.gz file that can be used with this setup needs to have the following structure:

::

"exampleconfig" (contains the solr configuration for the example collection)
    "conf"
        solrconfig.xml ...

::

2. Create a custom layer with the name "solrcloud"
    * Include the git repository as custom chef recipes
    * Map the custom recipes to the events:
        * Setup: opsworks_solrcloud::setup
        * Configure: opsworks_solrcloud::configure
        * Deploy: opsworks_solrcloud::deploy
        * Undeploy: opsworks_solrcloud::undeploy


Notes
========================

By now we use the first node in the cluster as exhibitor endpoint to
retrieve all active zookeeper nodes. It might make sence to run zookeeper and exhibitor
on another stack and support this in this cookbook.

How can i access the solr server and zookeeper?
========================

You can use:

http://anyclusternode:8080/exhibitor/v1/ui/index.html

to access the ui of the exhibitor, which is used to manage the zookeeper instances.

When the cookbook was executed successful you should also be able to access solr cloud with one
of the cluster hostname

e.g:

http://anyclusternode:8983/solr/

and your elastic load balancer should could also be configured to load balance requests to this port
to all active instances.

Resources
========================

Used cookbooks:

* https://github.com/vkhatri/chef-solrcloud
* https://github.com/SimpleFinance/chef-zookeeper
* https://github.com/SimpleFinance/chef-exhibitor
* https://github.com/opscode-cookbooks/java
* https://github.com/bmhatfield/chef-ulimit

Documentation:

* https://wiki.apache.org/solr/SolrCloud
* http://www.ngdata.com/a-first-exploration-of-solrcloud/


Other tools approaches to setup solr cloud
========================

Solr scale toolkit:

https://github.com/LucidWorks/solr-scale-tk

Cloudera CDH5:

http://www.cloudera.com/content/cloudera/en/downloads/cdh/cdh-5-2-0.html


.. |buildStatusIcon| image:: https://secure.travis-ci.org/timoschmidt/opsworks_solrcloud.png?branch=master
:alt: Build Status
   :target: http://travis-ci.org/timoschmidt/opsworks_solrcloud