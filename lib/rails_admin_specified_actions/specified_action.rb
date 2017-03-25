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
        _pb.call(target, self.args || {})
      else
        target and target.send(_pb, self.args)
      end
    else
      target and target.send(@name, self.args)
    end
  end

  register_instance_option :visible? do
    true
  end

  register_instance_option :can_view_backtrace do
    true
  end

  register_instance_option :process_block do
    true
  end

  register_instance_option :target do
    nil
  end

end
