action :install do
    # we run the solrcloud::tarball recipe here because i needs to run after all other recipes
    # when exhibitor and zookeeper is running
    run_context.include_recipe 'solrcloud::tarball'
end
