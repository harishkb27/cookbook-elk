#
# Cookbook Name:: elk
# Recipe:: default
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

# install Java
include_recipe 'java::default'

# create user and group
elk_es_user node['elk']['elasticsearch']['user'] do
  es_group node['elk']['elasticsearch']['group']
end

# install elasticsearch
elk_es_install 'elasticsearch'

# configure elasticsearch
elk_es_config 'elasticsearch'

# setup elasticsearch service
elk_es_service 'elasticsearch' do
  action [:enable, :start]
end

# install elasticsearch plugins
node['elk']['elasticsearch']['plugins'].each do |plugin|
  next if plugin[:plugin_name].to_s.empty?
  elk_es_plugin plugin[:plugin_name] do
  	plugin.each do |key, value|
      send(key, value) unless value.to_s.empty?
  	end
  end
end