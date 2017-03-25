require 'rails_admin/config/proxyable'
require 'rails_admin/config/configurable'
class RailsAdminSpecifiedActions::SpecifiedAction

  include RailsAdmin::Config::Proxyable
  include RailsAdmin::Config::Configurable

  attr_accessor :section, :defined, :order,
                :abstract_model, :root, :parent,
                :name, :args

  def initialize(_parent, _name, _args = {}, &block)
    @parent = _parent
    @root   = _parent.root
    @section = _parent

    @abstract_model = parent.abstract_model unless parent.is_a?(RailsAdmin::Config::Actions::SpecifiedActions)
    @defined = false
    @name = _name.to_sym
    @args   = _args || {}
    @process_block = block
  end

  def root?
    self.target == :root
  end
  def collection?
    self.target == :collection
  end
  def member?
    self.target == :member
  end


  def process(target)
    if (_pb = self.process_block)
      if _pb.respond_to?(:call)
        _pb.call(target, self.args)
      else
        puts _pb.inspect
        target and target.send(_pb, self.args)
      end
    else
      target and target.send(@name, self.args)
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
    true
  end

  register_instance_option :target do
    nil
  end

end
