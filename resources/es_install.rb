resource_name :elk_es_install

property :resource_name, String, name_property: true, required: true
property :install_dir, String, default: node['elk']['base_dir']
property :package_url, String, default: node['elk']['download_urls']['elasticsearch']
property :package_checksum, String, default: node['elk']['checksums']['elasticsearch']
property :version, String, default: node['elk']['versions']['elasticsearch']
property :es_user, String, default: node['elk']['elasticsearch']['user']
property :es_group, String, default: node['elk']['elasticsearch']['group']

action :install do

	ark new_resource.resource_name do
		url   new_resource.package_url
		owner new_resource.es_user
		group new_resource.es_group
		version new_resource.version
		has_binaries ['bin/elasticsearch', 'bin/elasticsearch-plugin']
		checksum new_resource.package_checksum
		prefix_root   new_resource.install_dir
		prefix_home   new_resource.install_dir

		not_if do
			link   = "#{new_resource.install_dir}/elasticsearch"
			target = "#{new_resource.install_dir}/elasticsearch-#{new_resource.version}"
			binary = "#{target}/bin/elasticsearch"

			::File.directory?(link) && ::File.symlink?(link) && ::File.readlink(link) == target && ::File.exist?(binary)
		end
	end
	
end

action :remove do

	link "#{new_resource.install_dir}/elasticsearch" do
		action :delete
		only_if do
			link   = "#{new_resource.install_dir}/elasticsearch"
			target = "#{new_resource.install_dir}/elasticsearch-#{new_resource.version}"

			::File.directory?(link) && ::File.symlink?(link) && ::File.readlink(link) == target
		end
	end

	directory "#{new_resource.install_dir}/elasticsearch-#{new_resource.version}" do
	  action :delete
	  recursive true
	end
	
end