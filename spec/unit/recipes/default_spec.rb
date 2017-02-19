#
# Cookbook Name:: elk
# Spec:: default
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'elk::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'creates an elasticsearch group with an elasticsearch user' do
    	expect(chef_run).to create_elk_es_user('elasticsearch').with(es_group: 'elasticsearch')
    end

    it 'installs elasticsearch' do
      expect(chef_run).to install_elk_es_install('elasticsearch')
    end

    it 'configures elasticsearch' do
      expect(chef_run).to configure_elk_es_config('elasticsearch')
    end

    it 'configures elasticsearch as a service' do
      expect(chef_run).to enable_elk_es_service('elasticsearch')
      expect(chef_run).to start_elk_es_service('elasticsearch')
    end

    it 'installs elasticsearch plugins' do
      expect(chef_run).to install_elk_es_plugin(/.?/)
    end
  end
end
