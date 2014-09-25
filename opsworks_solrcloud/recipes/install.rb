Chef::Log.info("Running opsworks solrcloud setup")

chef_gem "zk" do
  action :install
end

include_recipe 'solrcloud::tarball'