# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ocean"
  s.version = "1.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Peter Bengtson"]
  s.date = "2013-06-30"
  s.description = "This gem contains common Ruby and Rails code for Ocean."
  s.email = ["peter@peterbengtson.com"]
  s.files = ["lib/generators", "lib/generators/ocean_scaffold", "lib/generators/ocean_scaffold/ocean_scaffold_generator.rb", "lib/generators/ocean_scaffold/templates", "lib/generators/ocean_scaffold/templates/controller_specs", "lib/generators/ocean_scaffold/templates/controller_specs/create_spec.rb", "lib/generators/ocean_scaffold/templates/controller_specs/delete_spec.rb", "lib/generators/ocean_scaffold/templates/controller_specs/index_spec.rb", "lib/generators/ocean_scaffold/templates/controller_specs/show_spec.rb", "lib/generators/ocean_scaffold/templates/controller_specs/update_spec.rb", "lib/generators/ocean_scaffold/templates/model_spec.rb", "lib/generators/ocean_scaffold/templates/resource_routing_spec.rb", "lib/generators/ocean_scaffold/templates/view_specs", "lib/generators/ocean_scaffold/templates/view_specs/_resource_spec.rb", "lib/generators/ocean_scaffold/templates/views", "lib/generators/ocean_scaffold/templates/views/_resource.json.jbuilder", "lib/generators/ocean_scaffold/USAGE", "lib/generators/ocean_setup", "lib/generators/ocean_setup/ocean_setup_generator.rb", "lib/generators/ocean_setup/templates", "lib/generators/ocean_setup/templates/alive_controller.rb", "lib/generators/ocean_setup/templates/alive_routing_spec.rb", "lib/generators/ocean_setup/templates/alive_spec.rb", "lib/generators/ocean_setup/templates/api_constants.rb", "lib/generators/ocean_setup/templates/application_controller.rb", "lib/generators/ocean_setup/templates/application_helper.rb", "lib/generators/ocean_setup/templates/basic_ban_observer.rb", "lib/generators/ocean_setup/templates/config.yml.example", "lib/generators/ocean_setup/templates/development.rb", "lib/generators/ocean_setup/templates/errors_controller.rb", "lib/generators/ocean_setup/templates/gitignore", "lib/generators/ocean_setup/templates/hyperlinks.rb", "lib/generators/ocean_setup/templates/ocean_constants.rb", "lib/generators/ocean_setup/templates/production.rb", "lib/generators/ocean_setup/templates/routes.rb", "lib/generators/ocean_setup/templates/spec_helper.rb", "lib/generators/ocean_setup/templates/test.rb", "lib/generators/ocean_setup/templates/zeromq_logger.rb", "lib/generators/ocean_setup/USAGE", "lib/ocean", "lib/ocean/api.rb", "lib/ocean/api_resource.rb", "lib/ocean/flooding.rb", "lib/ocean/ocean_application_controller.rb", "lib/ocean/ocean_resource_controller.rb", "lib/ocean/ocean_resource_model.rb", "lib/ocean/selective_rack_logger.rb", "lib/ocean/version.rb", "lib/ocean/zero_log.rb", "lib/ocean/zeromq_logger.rb", "lib/ocean.rb", "lib/tasks", "lib/tasks/ocean_tasks.rake", "lib/template.rb", "lib/templates", "lib/templates/rails", "lib/templates/rails/scaffold_controller", "lib/templates/rails/scaffold_controller/controller.rb", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.homepage = "https://github.com/OceanDev/ocean"
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0")
  s.rubygems_version = "2.0.3"
  s.summary = "This gem contains common Ruby and Rails code for Ocean."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<faraday>, [">= 0"])
      s.add_runtime_dependency(%q<faraday_middleware>, [">= 0"])
      s.add_runtime_dependency(%q<typhoeus>, [">= 0"])
      s.add_runtime_dependency(%q<net-purge>, [">= 0"])
      s.add_runtime_dependency(%q<ffi-rzmq>, [">= 0"])
      s.add_runtime_dependency(%q<rack-attack>, [">= 0"])
      s.add_runtime_dependency(%q<jbuilder>, [">= 0"])
      s.add_development_dependency(%q<rails>, [">= 4.0.0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<rspec-rails>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<factory_girl_rails>, ["~> 4.0"])
    else
      s.add_dependency(%q<faraday>, [">= 0"])
      s.add_dependency(%q<faraday_middleware>, [">= 0"])
      s.add_dependency(%q<typhoeus>, [">= 0"])
      s.add_dependency(%q<net-purge>, [">= 0"])
      s.add_dependency(%q<ffi-rzmq>, [">= 0"])
      s.add_dependency(%q<rack-attack>, [">= 0"])
      s.add_dependency(%q<jbuilder>, [">= 0"])
      s.add_dependency(%q<rails>, [">= 4.0.0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<rspec-rails>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<factory_girl_rails>, ["~> 4.0"])
    end
  else
    s.add_dependency(%q<faraday>, [">= 0"])
    s.add_dependency(%q<faraday_middleware>, [">= 0"])
    s.add_dependency(%q<typhoeus>, [">= 0"])
    s.add_dependency(%q<net-purge>, [">= 0"])
    s.add_dependency(%q<ffi-rzmq>, [">= 0"])
    s.add_dependency(%q<rack-attack>, [">= 0"])
    s.add_dependency(%q<jbuilder>, [">= 0"])
    s.add_dependency(%q<rails>, [">= 4.0.0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<rspec-rails>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<factory_girl_rails>, ["~> 4.0"])
  end
end
