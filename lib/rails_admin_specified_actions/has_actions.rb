module RailsAdmin
  module Config
    # Provides accessors and autoregistering of model's fields.
    module HasActions
      # Defines a configuration for a field.
      def action(name, target = nil, args = {}, add_to_section = true, &block)
        action = _actions.detect { |a| name == a.name and (target.nil? or a.target == target) }

        # some fields are hidden by default (belongs_to keys, has_many associations in list views.)
        # unhide them if config specifically defines them
        # if action
        #   action.show unless action.instance_variable_get("@#{action.name}_registered").is_a?(Proc)
        # end
        # Specify field as virtual if type is not specifically set and field was not
        # found in default stack

        if action.nil? && args == {}
          action = (_actions << RailsAdminSpecifiedActions::SpecifiedAction.new(self, name, args)).last
        else
          if args && args != (action.nil? ? {} : action.args)
            if action
              # properties = action.properties
              action = _actions[_actions.index(action)] = RailsAdminSpecifiedActions::SpecifiedAction.new(self, name, args)
            else
              action = (_actions << RailsAdminSpecifiedActions::SpecifiedAction.new(self, name, args)).last
            end
          end
        end
        if target
          action.target do
            target
          end
        end

        # If field has not been yet defined add some default properties
        if add_to_section && !action.defined
          action.defined = true
          action.order = _actions.count(&:defined)
        end

        # If a block has been given evaluate it and sort fields after that
        action.instance_eval(&block) if block
        _actions
      end

      # configure a field without adding it.
      def configure(name, type = nil, &block)
        action(name, type, false, &block)
      end

      # include fields by name and apply an optionnal block to each (through a call to fields),
      # or include fields by conditions if no field names
      def include_actions(*action_names, &block)
        if action_names.empty?
          _actions.select { |a| a.instance_eval(&block) }.each do |a|
            next if a.defined
            a.defined = true
            # a.order = _actions.count(&:defined)
          end
        else
          actions(*action_names, &block)
        end
      end

      # exclude fields by name or by condition (block)
      def exclude_actions(*action_names, &block)
        block ||= proc { |a| action_names.include?(a.name) }
        _actions.each { |a| a.defined = true } if _actions.select(&:defined).empty?
        _actions.select { |a| a.instance_eval(&block) }.each { |a| a.defined = false }
      end

      # API candy
      alias_method :exclude_actions_if, :exclude_actions
      alias_method :include_actions_if, :include_actions

      def include_all_actions
        include_actions_if { true }
      end

      # Returns all field configurations for the model configuration instance. If no fields
      # have been defined returns all fields. Defined fields are sorted to match their
      # order property. If order was not specified it will match the order in which fields
      # were defined.
      #
      # If a block is passed it will be evaluated in the context of each field
      def actions(*action_names, &block)
        return all_actions if action_names.empty? && !block

        if action_names.empty?
          defined = _actions.select(&:defined)
          defined = _actions if defined.empty?
        else
          defined = action_names.collect { |action_name| _actions.detect { |a| a.name == action_name } }
        end
        defined.collect do |a|
          unless a.defined
            a.defined = true
            # a.order = _actions.count(&:defined)
          end
          a.instance_eval(&block) if block
          a
        end
      end

      # Defines configuration for fields by their type.
      # def fields_of_type(type, &block)
      #   _fields.select { |f| type == f.type }.map! { |f| f.instance_eval(&block) } if block
      # end

      # Accessor for all fields
      def all_actions
        ((ro_actions = _actions(true)).select(&:defined).presence || ro_actions).collect do |a|
          # a.section = self
          a
        end
      end

      # Get all fields defined as visible, in the correct order.
      def visible_actions
        i = 0
        # all_actions.collect { |a| a.with(bindings) }.select(&:visible?).sort_by { |a| [a.order, i += 1] } # stable sort, damn
        all_actions.collect { |a| a.with(bindings) }.select(&:visible?)
      end

    protected

      # Raw fields.
      # Recursively returns parent section's raw fields
      # Duping it if accessed for modification.
      def _actions(readonly = false)
        return @_actions if @_actions
        return @_ro_actions if readonly && @_ro_actions

        if self.class == RailsAdmin::Config::Sections::Base
          @_ro_actions = @_actions = [] #RailsAdmin::Config::Fields.factory(self)
        else
          # parent is RailsAdmin::Config::Model, recursion is on Section's classes
          if respond_to?(:parent) and parent
            @_ro_actions ||= parent.send(self.class.superclass.to_s.underscore.split('/').last)._actions(true).freeze
          else
            RailsAdmin::Config.specified_actions ||= []
            @_ro_actions ||= RailsAdmin::Config.specified_actions
            return readonly ? @_ro_actions : (RailsAdmin::Config.specified_actions ||= @_ro_actions.collect(&:clone))
          end
        end
        readonly ? @_ro_actions : (@_actions ||= @_ro_actions.collect(&:clone))
      end
    end
  end
end
