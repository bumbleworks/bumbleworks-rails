<% if storage_config_path -%>
require 'yaml'
storage_config = YAML.load_file('<%= storage_config_path %>')[Rails.env]

<% end -%>
Bumbleworks.configure do |c|
  c.storage = <%= storage %>
<% if storage_options.present? -%>
  c.storage_options = <%= storage_options %>
<% end -%>
end

Bumbleworks.initialize!