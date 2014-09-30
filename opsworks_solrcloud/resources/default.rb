actions(:install)
default_action(:install)

attribute :public_dns_name,     kind_of: String, name_attribute: true
attribute :force_exibitor_uri,   kind_of: String
attribute :use_first_node,      kind_of: [TrueClass, FalseClass], default: true