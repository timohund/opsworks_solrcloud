Solr cloud chef cookbook for Amazon AWS OpsWorks
==================

This cookbook can be used to install SolrCloud on an aws OpsWorks stack.

It uses the solrcloud cookbooks to install solr in a cloud mode with an external zookeeper service.
By now we install zookeeper on each node and use exhibitor to discover the zookeeper instances
with our chef cookbook

## Usage

You need to:

1. Create a new stack
    * Enable "Manage Berkshelf"
    * Use Berkshelf version 3.1.3

2. Create a custom layer
    * Include the git repository as custom chef recipes
    * Map the custom recipes to the events:
        * Setup: opsworks_solrcloud::setup
        * Configure: opsworks_solrcloud::configure


## Notes

By now we use the first node in the cluster as exhibitor endpoint to
retrieve all active zookeeper nodes. It might make sence to run zookeeper and exhibitor
on another stack and support this in this cookbook.

## Resources

* https://github.com/vkhatri/chef-solrcloud.git
* https://github.com/SimpleFinance/chef-zookeeper
* https://github.com/SimpleFinance/chef-exhibitor