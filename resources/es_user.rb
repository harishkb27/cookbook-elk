resource_name :elk_es_user

property :resource_name, String, name_property: true, required: true
property :es_group, String, required: true

default_action :create

action :create do

	user new_resource.resource_name do
		action :create
	end

	group new_resource.es_group do
		action :create
		members new_resource.resource_name
	end
	
end

action :remove do

	user new_resource.resource_name do
		action :remove
	end

	group new_resource.es_group do
		action :remove
	end
	
end