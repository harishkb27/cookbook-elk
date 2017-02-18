if defined?(ChefSpec)

  ChefSpec.define_matcher :elk_es_user
  ChefSpec.define_matcher :elk_es_install
  ChefSpec.define_matcher :elk_es_config
  ChefSpec.define_matcher :elk_es_service

  def create_elk_es_user(resource_name)
  	ChefSpec::Matchers::ResourceMatcher.new(:elk_es_user, :create, resource_name)
  end

  def remove_elk_es_user(resource_name)
  	ChefSpec::Matchers::ResourceMatcher.new(:elk_es_user, :remove, resource_name)
  end

  def install_elk_es_install(resource_name)
	ChefSpec::Matchers::ResourceMatcher.new(:elk_es_install, :install, resource_name)
  end

  def remove_elk_es_install(resource_name)
	ChefSpec::Matchers::ResourceMatcher.new(:elk_es_install, :remove, resource_name)
  end

  def configure_elk_es_config(resource_name)
	ChefSpec::Matchers::ResourceMatcher.new(:elk_es_config, :configure, resource_name)
  end

  def remove_elk_es_config(resource_name)
	ChefSpec::Matchers::ResourceMatcher.new(:elk_es_config, :remove, resource_name)
  end

  def enable_elk_es_service(resource_name)
	ChefSpec::Matchers::ResourceMatcher.new(:elk_es_service, :enable, resource_name)
  end

  def start_elk_es_service(resource_name)
	ChefSpec::Matchers::ResourceMatcher.new(:elk_es_service, :start, resource_name)
  end

  def stop_elk_es_service(resource_name)
	ChefSpec::Matchers::ResourceMatcher.new(:elk_es_service, :stop, resource_name)
  end

  def restart_elk_es_service(resource_name)
	ChefSpec::Matchers::ResourceMatcher.new(:elk_es_service, :restart, resource_name)
  end

  def disable_elk_es_service(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:elk_es_service, :disable, resource_name)
  end

  def status_elk_es_service(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:elk_es_service, :status, resource_name)
  end

end