resource_name :elk_es_config

property :resource_name, String, name_property: true, required: true

# user and group
property :es_user, String, default: node['elk']['elasticsearch']['user']
property :es_group, String, default: node['elk']['elasticsearch']['group']

# path properties
property :conf_path, String, default: node['elk']['elasticsearch']['paths']['conf']
property :data_path, String, default: node['elk']['elasticsearch']['paths']['data']
property :logs_path, String, default: node['elk']['elasticsearch']['paths']['logs']
property :home_path, String, default: node['elk']['elasticsearch']['paths']['home']
property :sysconfig_path, String, default: node['elk']['elasticsearch']['paths']['sysconfig']
property :pid_path, String, default: node['elk']['elasticsearch']['paths']['pid']
property :plugins_path, String, default: node['elk']['elasticsearch']['paths']['plugins']
property :java_home, String, default: node['java']['home']

# configuration
property :configuration, Hash, default: node['elk']['elasticsearch']['configuration']

# templates
property :env_template, String, default: 'elasticsearch.in.sh.erb' 
property :jvm_template, String, default: 'jvm_options.erb'
property :yml_template, String, default: 'elasticsearch.yml.erb'
property :log4j2_template, String, default: 'log4j2.properties.erb'

# env properties
property :memlock_limit, String, default: 'unlimited'
property :max_map_count, String, default: '262144'
property :nofile_limit, String, default: '65536'
property :startup_sleep_seconds, [String, Integer], default: 5
property :restart_on_upgrade, [TrueClass, FalseClass], default: false
property :allocated_memory, String

property :jvm_options, Array, default:
  %w(
    -XX:+UseConcMarkSweepGC
    -XX:CMSInitiatingOccupancyFraction=75
    -XX:+UseCMSInitiatingOccupancyOnly
    -XX:+DisableExplicitGC
    -XX:+AlwaysPreTouch
    -server
    -Djava.awt.headless=true
    -Dfile.encoding=UTF-8
    -Djna.nosys=true
    -Dio.netty.noUnsafe=true
    -Dio.netty.noKeySetOptimization=true
    -Dlog4j.shutdownHookEnabled=false
    -Dlog4j2.disable.jmx=true
    -Dlog4j.skipJansi=true
    -XX:+HeapDumpOnOutOfMemoryError
  ).freeze

default_action :configure

action_class do
	
	def allocated_memory
	  @allocated_memory ||= calculate_allocated_memory
	end

	def calculate_allocated_memory
	  node_memory_half = ((node['memory']['total'].to_i * 0.5).floor / 1024)
	  allocated_memory = (node_memory_half > 30500 ? '30500m' : "#{node_memory_half}m")
	  allocated_memory
	end

  def search_master_nodes

    if Chef::Config[:solo]
      ["127.0.0.1", "[::1]"]
    else
      master_hosts = []
      search(:node, "cluster_name:elasticsearch AND node_master:true", filter_result: {fqdn: [:fqdn]}).each do |host|
        master_hosts << host['fqdn']
      end
      master_hosts = master_hosts.any? ? master_hosts.sort.uniq : ["127.0.0.1", "[::1]"]
      master_hosts
    end
  rescue
    ["127.0.0.1", "[::1]"]
  end

  def master_eligible_hosts
    master_hosts_attr = node['elk']['elasticsearch']['configuration']['master_hosts']
    master_hosts = master_hosts_attr.empty? ? search_master_nodes : master_hosts_attr
  end

  def minimum_master_nodes(master_hosts)
    master_hosts.length / 2 + 1
  end

end

action :configure do

  execute "sysctl vm max_map_count" do
    command "sysctl -w vm.max_map_count=#{new_resource.max_map_count}"
    only_if "[[ $(sysctl -n vm.max_map_count) -ne #{new_resource.max_map_count} ]]"
    action :run
  end
  
  [new_resource.conf_path, new_resource.logs_path, new_resource.plugins_path, "#{new_resource.conf_path}/scripts"].each do |path|
  	directory path do
  	  owner new_resource.es_user
  	  group new_resource.es_group
  	  mode '0750'
  	  recursive true
  	  action :create
  	end
  end

  data_paths = new_resource.data_path.is_a?(Array) ? new_resource.data_path : new_resource.data_path.split(',')
  data_paths.each do |path|
  	directory path do
  	  owner new_resource.es_user
  	  group new_resource.es_group
  	  mode '0755'
  	  recursive true
  	  action :create
  	end
  end

  params = {}
  params[:ES_HOME] = new_resource.home_path
  params[:JAVA_HOME] = new_resource.java_home
  params[:CONF_DIR] = new_resource.conf_path
  params[:DATA_DIR] = new_resource.data_path
  params[:LOG_DIR] = new_resource.logs_path
  params[:PID_DIR] = new_resource.pid_path
  params[:RESTART_ON_UPGRADE] = new_resource.restart_on_upgrade
  params[:ES_USER] = new_resource.es_user
  params[:ES_GROUP] = new_resource.es_group
  params[:ES_STARTUP_SLEEP_TIME] = new_resource.startup_sleep_seconds.to_s
  params[:MAX_OPEN_FILES] = new_resource.nofile_limit
  params[:MAX_LOCKED_MEMORY] = new_resource.memlock_limit
  params[:MAX_MAP_COUNT] = new_resource.max_map_count
  params[:ES_JVM_OPTIONS] = "#{new_resource.conf_path}/jvm.options"

  template "elasticsearch.in.sh" do
  	path new_resource.sysconfig_path
  	source new_resource.env_template
  	mode '0644'
  	variables(params: params)
  	action :create
  end
  
  jvm_opts = [
    "-Xms#{allocated_memory}",
    "-Xmx#{allocated_memory}",
    new_resource.jvm_options,
  ].flatten.join("\n")

  template "jvm_options" do
  	path "#{new_resource.conf_path}/jvm.options"
  	source new_resource.jvm_template
  	mode '0644'
  	owner new_resource.es_user
  	group new_resource.es_group
  	variables(jvm_options: jvm_opts)
  	action :create
    notifies :restart, 'elk_es_service[elasticsearch]', :delayed
  end

  template "log4j2_properties" do
    path   "#{new_resource.conf_path}/log4j2.properties"
    source new_resource.log4j2_template
    owner new_resource.es_user
    group new_resource.es_group
    mode '0750'
    action :create
    notifies :restart, 'elk_es_service[elasticsearch]', :delayed
  end

  master_hosts = master_eligible_hosts
  template "elasticsearch.yml" do
    path "#{new_resource.conf_path}/elasticsearch.yml"
    source new_resource.yml_template
    owner new_resource.es_user
    group new_resource.es_group
    mode '0750'
    variables({
      cluster_name: new_resource.configuration['cluster_name'],
      node_name: new_resource.configuration['node_name'],
      node_data: new_resource.configuration['node_data'],
      node_master: new_resource.configuration['node_master'],
      path_data: new_resource.data_path,
      path_logs: new_resource.logs_path,
      path_conf: new_resource.conf_path,
      master_hosts: master_hosts,
      minimum_master_nodes: minimum_master_nodes(master_hosts)
    })
    action :create
    notifies :restart, 'elk_es_service[elasticsearch]', :delayed
  end
end

action :remove do
	
  data_paths = new_resource.data_path.is_a?(Array) ? new_resource.data_path : new_resource.data_path.split(',')
  ([new_resource.conf_path, new_resource.logs_path] + data_paths).each do |path|
    directory path do
      recursive true
      action :delete
    end
  end

  file new_resource.sysconfig_path do
    action :delete
  end

end