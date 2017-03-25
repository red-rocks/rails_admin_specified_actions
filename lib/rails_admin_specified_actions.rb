require "rails_admin_specified_actions/version"
require "rails_admin_specified_actions/engine"

module RailsAdminSpecifiedActions

  class << self
    def root_actions(config)
      
    end
  end

end

require "rails_admin"
require "rails_admin_specified_actions/rails_admin_patch"

require "rails_admin_specified_actions/specified_action"
require "rails_admin_specified_actions/action"
require "rails_admin_specified_actions/model"
