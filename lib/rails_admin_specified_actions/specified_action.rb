require 'rails_admin/config/proxyable'
require 'rails_admin/config/configurable'
class RailsAdminSpecifiedActions::SpecifiedAction

  include RailsAdmin::Config::Proxyable
  include RailsAdmin::Config::Configurable

  attr_accessor :section, :defined, :order,
                :abstract_model, :root, :parent,
                :name

  def initialize(_parent, _name, _args = {}, &block)
    @parent = _parent
    @root   = _parent.root
    @section = _parent

    @abstract_model = parent.abstract_model unless parent.is_a?(RailsAdmin::Config::Actions::SpecifiedActions)
    @defined = false
    @name = _name.to_sym
    args   = _args || {}
    @process_block = block
  end

  def root?
    @root
    # @parent.nil? or @parent == @root
    # self.target == :root
  end
  def collection?
    @parent.is_a? RailsAdmin::Config::Sections::SpecifiedActionsForCollection
    # self.target == :collection
  end
  def member?
    @parent.is_a? RailsAdmin::Config::Sections::SpecifiedActionsForMember
    # self.target == :member
  end

  # private :do_process
  def do_process(target, args)
    if (_pb = self.process_block)
      if _pb.respond_to?(:call)
        begin
          _pb.call(target, args)
        rescue
          _pb.call(target)
        end
      else
        begin
          target and target.try(_pb, args)
        rescue
          target and target.try(_pb)
        end
      end
    else
      begin
        target and target.try(@name, args)
      rescue
        target and target.try(@name)
      end
    end
  end


  def process(target, args)
    return threaded_process(target, args) if self.threaded
    do_process(target, args)
  end

  def threaded_process(target, args)
    Thread.new(self, target, args) do |action, target, args|
      action.do_process(target, args)
    end
  end

  register_instance_option :label do
    name
  end

  register_instance_option :visible? do
    true
  end

  register_instance_option :can_view_error_backtrace do
    cont = (bindings and bindings[:controller])
    cu =  (cont and cont._current_user)
    if cu
      if cont.respond_to?(:can?)
        cont.can?(:view_error_backtrace, self)
      elsif cu.respond_to?(:can_view_error_backtrace)
        cu.can_view_error_backtrace
      elsif cu.respond_to?(:admin?)
        cu.admin?
      end
    else
      false
    end
  end

  register_instance_option :can_view_error_message do
    cont = (bindings and bindings[:controller])
    cu =  (cont and cont._current_user)
    if cu
      if cont.respond_to?(:can?)
        cont.can?(:view_error_message, self)
      elsif cu.respond_to?(:can_view_error_message)
        cu.can_view_error_message
      elsif cu.respond_to?(:admin?)
        cu.admin?
      end
    else
      false
    end
  end

  register_instance_option :process_block do
    nil #true
  end

  register_instance_option :target do
    nil
  end

  register_instance_option :ajax do
    false
  end

  register_instance_option :threaded do
    false
  end

  register_instance_option :object do
    nil
  end

  register_instance_option :args do
    {}
  end

end
