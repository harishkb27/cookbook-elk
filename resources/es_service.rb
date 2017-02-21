resource_name :elk_es_service

property :resource_name, String, name_property: true, required: true
property :systemd_source, String, default: 'systemd_unit.erb'
property :es_user, String, default: node['elk']['elasticsearch']['user']
property :es_group, String, default: node['elk']['elasticsearch']['group']
property :pid_path, String, default: node['elk']['elasticsearch']['paths']['pid']

default_action :enable

action_class do

  def configure
	directory new_resource.pid_path do
	  owner new_resource.es_user
	  group new_resource.es_group
	  mode '0755'
	  recursive true
	  action :create
	end

	directory "/usr/lib/systemd/system" do
	  action :create
	  only_if { ::File.exist?('/usr/lib/systemd') }
	end

	template "/usr/lib/systemd/system/#{new_resource.resource_name}.service" do
	  source new_resource.systemd_source
	  owner 'root'
	  mode '0644'
	  variables(
	    program_name: new_resource.resource_name,
	    default_dir: '/etc/sysconfig',
	    es_user: new_resource.es_user,
	    es_group: new_resource.es_group
	  )
	  only_if 'which systemctl'
	  action :create
	end

	execute "reload-systemd-#{new_resource.resource_name}" do
	  command 'systemctl daemon-reload'
	  action :nothing
	  only_if 'which systemctl'
	  subscribes :run, "template[/usr/lib/systemd/system/#{new_resource.resource_name}.service]", :immediately
	  notifies :restart, "elk_es_service[#{new_resource.resource_name}]", :delayed
	end
  end

  def run_service(action)
    service new_resource.resource_name do
      supports status: true, restart: true
	  action action
	end
  end
  
end

action :enable do
  configure
  run_service(:enable)
end

action :start do
  run_service(:start)
end

action :stop do
  run_service(:stop)
end

action :restart do
  run_service(:restart)
end

action :disable do
  run_service(:disable)
end

action :status do
  run_service(:status)
end