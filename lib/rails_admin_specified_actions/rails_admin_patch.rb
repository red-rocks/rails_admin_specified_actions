require 'rails_admin/config'
module RailsAdmin
  module Config

    class << self
      attr_accessor :specified_actions
    end

  end
end
