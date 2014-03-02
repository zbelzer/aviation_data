require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

require File.expand_path("../../lib/core", __FILE__)

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module AviationData
  class Application < Rails::Application
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true
    config.autoload_paths += ["#{config.root}/lib", "#{config.root}/app"]

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    initializer 'core.load_engine' do
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.class_eval do
          include Core::Aggregatable
          include Core::HasEnumeratedSti
          include Core::Trackable
          include Core::AliasAssociation
          include Core::Behaviors
        end
      end

      ActiveSupport::Inflector.inflections do |inflector|
        inflector.plural(/^(\w+_info)$/, '\1')
      end
    end
  end
end
