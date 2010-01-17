unless defined?(Sass::RAILS_LOADED)
  Sass::RAILS_LOADED = true

  Sass::Plugin.options.merge!(:template_location => Haml::Util.rails_root + '/public/stylesheets/sass',
                              :css_location      => Haml::Util.rails_root + '/public/stylesheets',
                              :cache_location    => Haml::Util.rails_root + '/tmp/sass-cache',
                              :always_check      => RAILS_ENV != "production",
                              :full_exception    => RAILS_ENV != "production")

  if defined?(Rails.configuration.middleware)
    # Rails >= 3.0
    require 'sass/plugin/rack'
    Rails.configuration.middleware.use(Sass::Plugin::Rack)
  elsif defined?(ActionController::Dispatcher.middleware)
    # Rails >= 2.3
    require 'sass/plugin/rack'
    ActionController::Dispatcher.middleware.use(Sass::Plugin::Rack)
  else
    module ActionController
      class Base
        alias_method :sass_old_process, :process
        def process(*args)
          Sass::Plugin.check_for_updates
          sass_old_process(*args)
        end
      end
    end
  end
end
