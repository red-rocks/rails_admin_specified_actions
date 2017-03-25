require 'rails_admin/config/actions/base'
require "rails_admin_specified_actions/specified_action"
require "rails_admin_specified_actions/has_actions"

module RailsAdmin
  module Config
    module Sections
      class Base

        include RailsAdmin::Config::HasActions

      end
    end
  end
end

require 'rails_admin/config'
module RailsAdmin
  module Config

    class << self
      attr_accessor :specified_actions
    end

  end
end
