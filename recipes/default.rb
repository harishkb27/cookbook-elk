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