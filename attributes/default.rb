# Java
default['java']['jdk_version'] = 8
default['java']['home'] = '/usr/lib/jvm/java-1.8.0'

#Elasticsearch
default['elk']['download_urls'] = {
	'elasticsearch' => 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.0.0.tar.gz'
}

default['elk']['checksums'] = {
	'elasticsearch' => 'a866534f0fa7428e980c985d712024feef1dee04709add6e360fc7b73bb1e7ae'
}

default['elk']['versions'] = {
	'elasticsearch' => '5.0.0'
}

default['elk']['elasticsearch']['user'] = 'elasticsearch'
default['elk']['elasticsearch']['group'] = 'elasticsearch'

default['elk']['base_dir'] = '/usr/share'
default['elk']['elasticsearch']['paths'] = {
	'home' => "#{node['elk']['base_dir']}/elasticsearch",
	'conf' => '/etc/elasticsearch',
	'data' => '/var/lib/elasticsearch',
	'logs' => '/var/log/elasticsearch',
	'sysconfig' => '/etc/sysconfig/elasticsearch',
	'pid' => '/var/run/elasticsearch',
	'plugins' => "#{node['elk']['base_dir']}/elasticsearch/plugins",
}

# if master_hosts is not provided, a chef search is carried out.
default['elk']['elasticsearch']['configuration'] = {
	'cluster_name' => 'elasticsearch',
	'node_name' => node['hostname'],
	'node_data' => true,
	'node_master' => true,
	'master_hosts' => []
}

# Please stick to {'plugin_name': '', 'url': '', 'options': ''}
default['elk']['elasticsearch']['plugins'] = [
  {'plugin_name': 'x-pack'}
]