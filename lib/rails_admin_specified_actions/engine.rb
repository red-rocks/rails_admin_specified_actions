module RailsAdminSpecifiedActions
  class Engine < ::Rails::Engine

    initializer "RailsAdminSpecifiedActions precompile hook", group: :all do |app|
      app.config.assets.precompile += %w(rails_admin/rails_admin_specified_actions.js rails_admin/rails_admin_specified_actions.css)
    end
    
  end
end
