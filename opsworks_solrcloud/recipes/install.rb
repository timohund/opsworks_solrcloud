message = node.has_key?(:message) ? node[:message] : "Hello World"

execute "echo message" do
  command "echo '#{message}' opsworks_solrcloud install"
  action :run
end
