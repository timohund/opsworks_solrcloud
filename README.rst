++++++++++++++++++++++++
SolrCloud cookbook for AWS OpsWorks
++++++++++++++++++++++++

:Author: AOE <dev@aoe.com>
:Author: Timo Schmidt
:Author: Nikolay Diaur
:Author: Michael Klapper
:Description: Cookbook to install SolrCloud on an AWS OpsWorks stack
:Build status: |buildStatusIcon|

Foreword
========================

This cookbook can be used to install SolrCloud on an AWS OpsWorks stack.

It uses multiple community cookbooks to install a copy of

* SolrCloud, which does some nifty document searching
* ZooKeeper, which holds configuration information for and helps network SolrCloud
* Exhibitor, which helps visualize ZooKeeper instances

on each node.

What do i need to configure?
========================

You need to:

1. Create a tarball containing your SolrCloud configuration files, namespacing each Collection's
   config files within their own folder. I.e. if you had two collections called "example1" and "example2",
   your file might look like:

::

  configs.tar.gz
     example1_config/
         conf/
             solrconfig.xml
             schema.xml
             ... etc ...
     example2_config/
         conf/
             solrconfig.xml
             schema.xml
             ... etc ...

::

Upload this file to S3 and create the IAM credentials SolrCloud should fetch it with.
IAM Role-based authentication is not yet supported by the underlying s3_file resource.

2. Create a new stack (easiest) or modify an existing stack
    * Enable "Use Custom Cookbooks" and either point to this repo or include it in your own
    * Enable "Manage Berkshelf" (to enable the evaluation of the included Berksfile)
    * Use Berkshelf version 3.1.3
    * Add this below to your custom stack json configuration:

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

The opsworks_solrcloud block specifies the S3 bucket location of the initial config
tarball and the credentials to fetch it with. The solrcloud "zkconfigsets" and "collections" blocks specify
which configs to upload to ZooKeeper when running the deploy recipe.

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


2. Create a custom layer with the name "solrcloud"
    * Map the custom recipes provided by this repo to the events:
        * Setup: opsworks_solrcloud::setup
        * Configure: opsworks_solrcloud::configure
        * Deploy: opsworks_solrcloud::deploy
        * Undeploy: opsworks_solrcloud::undeploy

3. Once you have your first instance up and running, either deploy any app to it or manually run the
   opsworks_solrcloud::deploy recipe to fetch and apply the initial configuration from S3 to ZooKeeper.

You're now ready to setup your SolrCloud cores, create new instances and watch
ZooKeeper sync, then create more cores there, etc.

How can i access the solr server and zookeeper?
========================

You can use:

http://anyclusternode:8080/exhibitor/v1/ui/index.html

to access the ui of the exhibitor, which is used to manage the zookeeper instances.

When the cookbook was executed successfully you should also be able to access solr cloud with one
of the cluster hostname

e.g:

http://anyclusternode:8983/solr/

and your elastic load balancer should could also be configured to load balance requests to this port
to all active instances.

Notes
========================

We currently use the first node in the cluster as exhibitor endpoint to
retrieve all active zookeeper nodes. It might make sense to run zookeeper and exhibitor
on another stack and support this in this cookbook.

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