# require 'rails_admin/config/sections'
require 'rails_admin/config/sections/list'
require 'rails_admin_specified_actions/has_actions'

module RailsAdmin
  module Config
    module Sections
      # Configuration of the explore view
      class SpecifiedActions < Base
        include RailsAdmin::Config::HasActions
      end
      class SpecifiedActionsForCollection < SpecifiedActions
      end
      class SpecifiedActionsForMember < SpecifiedActions
      end
    end
  end
end
RailsAdmin::Config::Model.send :include, RailsAdmin::Config::Sections
