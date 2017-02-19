require 'spec_helper'

# test user and group resources

es_user = 'elasticsearch'
es_group = 'elasticsearch'

describe group(es_group) do
	it {should exist}
end

describe user(es_user) do
	it {should exist}
	it {should belong_to_group es_group}
end

# test elasticsearch install

elk_es_home = '/usr/share/elasticsearch'
es_version = '5.0.0'

describe file("#{elk_es_home}-#{es_version}") do
	it {should be_directory}
	it {should be_owned_by es_user}
	it {should be_grouped_into es_group}
end

describe file('/usr/local/bin/elasticsearch') do
	it {should be_symlink}
	it {should be_linked_to "#{elk_es_home}-#{es_version}/bin/elasticsearch"}
end

# test elasticsearch configuration

expected_environment = [
  'CONF_DIR=.+',
  'DATA_DIR=.+',
  'ES_GROUP=.+',
  'ES_HOME=.+',
  'ES_STARTUP_SLEEP_TIME=.+',
  'ES_USER=.+',
  'LOG_DIR=.+',
  'MAX_LOCKED_MEMORY=.+',
  'MAX_MAP_COUNT=.+',
  'MAX_OPEN_FILES=.+',
  'PID_DIR=.+',
  'RESTART_ON_UPGRADE=.+',
]

expected_config = [
  'cluster.name: elasticsearch',
  'node.name: .+',
  'path.conf: \/.+',
  'path.data: \/.+',
  'path.logs: \/.+',
]

expected_jvm_options = [
  'server',
  'HeapDumpOnOutOfMemoryError',
  'java.awt.headless=true',
]

describe file('/var/lib/elasticsearch') do
  it {should be_directory}
  it {should be_mode 755}
  it {should be_owned_by es_user}
  it {should be_grouped_into es_group}
end

['/etc/elasticsearch', '/var/log/elasticsearch'].each do |p|
  describe file(p) do
  	it {should be_directory}
    it {should be_mode 750}
    it {should be_owned_by es_user}
    it {should be_grouped_into es_group}
  end
end

describe file('/etc/sysconfig/elasticsearch') do
  it {should be_file}
  it {should be_mode 644}
  
  expected_environment.each do |line|
  	its(:content) {should contain(/#{line}/)}
  end
end

describe file('/etc/elasticsearch/elasticsearch.yml') do
  it {should be_file}
  it {should be_mode 750}
  it {should be_owned_by es_user}
  it {should be_grouped_into es_group}

  expected_config.each do |line|
  	its(:content) {should contain(/#{line}/)}
  end
end

describe file("/etc/elasticsearch/jvm.options") do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by es_user }
  it { should be_grouped_into es_group }

  expected_jvm_options.each do |line|
    its(:content) { should contain(/#{line}/) }
  end
end

 describe file("/etc/elasticsearch/log4j2.properties") do
  it { should be_file }
  it { should be_mode 750 }
  it { should be_owned_by es_user }
  it { should be_grouped_into es_group }
 end

# test elasticsearch service

describe service('elasticsearch') do
  it {should be_enabled}
  it {should be_running}
end

describe command('sleep 30') do
  its(:exit_status) { should eq 0 }
end

describe command('curl http://elastic:changeme@localhost:9200') do
  its(:stdout) { should match(/elasticsearch/) }
end

# test elasticsearch plugin

plugins = ['x-pack']

plugins.each do |plugin|
  describe file("#{elk_es_home}/plugins/#{plugin}") do
    it { should be_directory }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end

describe command('curl http://elastic:changeme@localhost:9200/_nodes/plugins') do
  plugins.each do |plugin|
    its(:stdout) { should match(/#{plugin}/) }
  end
end