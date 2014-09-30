opsworks_solrcloud
==================

This cookbook can be used to install SolrCloud on an aws OpsWorks stack.

You need to:

1. Create a new stack
    * Enable "Manage Berkshelf"
    * Use Berkshelf version 3.1.3

2. Create a custom layer
    * Include the git repository as custom chef recipes
    * Map the custome recepies to the events:
        * Setup: opsworks_solrcloud::setup
        * Configure: opsworks_solrcloud::configure
