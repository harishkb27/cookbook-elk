resource_name :elk_es_plugin

property :plugin_name, String, name_property: true, required: true
property :url, String
property :options, String, default: ''
property :home_path, String, default: node['elk']['elasticsearch']['paths']['home']
property :plugins_path, String, default: node['elk']['elasticsearch']['paths']['plugins']
property :sysconfig_path, String, default: node['elk']['elasticsearch']['paths']['sysconfig']

default_action :install

action_class do
  
  def plugin_exists(plugin_name)
    Dir.entries(new_resource.plugins_path).any? do |plugin|
      next if plugin =~ /^\./
      name == plugin
    end
  rescue
  	false
  end

  def check_es_install
  	unless ::File.exist?("#{new_resource.home_path}/bin/elasticsearch-plugin")
  	  raise "Plugin binary NotFound - #{new_resource.home_path}/bin/elasticsearch-plugin"
  	end
  	unless ::Dir.exist?(new_resource.plugins_path)
  	  raise "Plugin directory NotFound - #{new_resource.plugins_path}"
  	end
  end

  def install_plugin(url_or_name)
  	command_string = "#{new_resource.home_path}/bin/elasticsearch-plugin install #{url_or_name.chomp(' ')} #{new_resource.options}".chomp(' ')
  	execute "install #{url_or_name}" do
  	  command command_string
  	  action :run
  	  environment ({
  	  	'ES_INCLUDE' => new_resource.sysconfig_path
  	  })
  	  notifies :restart, 'elk_es_service[elasticsearch]', :delayed
  	end
  end

end

action :install do
  unless plugin_exists(new_resource.plugin_name)
    url_or_name = new_resource.url || new_resource.plugin_name
    check_es_install
    install_plugin(url_or_name)
  end
end

action :remove do

end