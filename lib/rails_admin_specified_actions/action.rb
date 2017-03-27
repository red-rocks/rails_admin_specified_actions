require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

require 'rails_admin_specified_actions/specified_action'

module RailsAdmin
  module Config
    module Actions
      class SpecifiedActions < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        include RailsAdmin::Config::HasActions

        register_instance_option :root? do
          true
        end

        register_instance_option :collection? do
          false
        end

        register_instance_option :member do
          false
        end

        register_instance_option :pjax? do
          false
        end

        register_instance_option :route_fragment do
          'specified_actions'
        end

        register_instance_option :template_name do
          'specified_actions'
        end

        register_instance_option :controller do
          proc do
            def fallback_location
              if @object
                specified_actions_for_member_path(model_name: @abstract_model, id: @object.id)
              elsif @abstract_model
                specified_actions_for_collection_path(model_name: @abstract_model)
              else
                specified_actions_path
              end
            end
            if @object
              @actions_list = (@model_config.specified_actions_for_member || []).select(&:member?)
            elsif @abstract_model
              @actions_list = (@model_config.specified_actions_for_collection || []).select(&:collection?)
            else
              @actions_list = (RailsAdmin::Config.specified_actions || []).select(&:root?)
            end
            @actions_list.map! { |a| a.with({controller: self, object: @object, model: (@abstract_model and @abstract_model.model)}) }

            if request.get? # Actions list
              respond_to do |format|
                format.html { render @action.template_name }
                format.js   { render @action.template_name, layout: false }
              end

            elsif request.post? # Do action

              if (_action = @actions_list.find { |a| a.name == params[:specified_action][:name].to_sym })
                args = (params[:specified_action][:args] || {})
                begin
                  @result = _action.process(@object || (@abstract_model and @abstract_model.model))
                rescue Exception => ex
                  @error_message    = _action.can_view_error_message ? ex.message : "Произошла ошибка ;("
                  @error_backtrace  = ex.backtrace.join("\n") if _action.can_view_error_backtrace
                end
                @result = "Задача выполняется" if @result.is_a?(Thread)
                @result ||= "Успешно!"
                respond_to do |format|
                  format.html {
                    # render @action.template_name
                    flash[:info] = "Попытка выполнения '#{_action.name}':"
                    flash[:success] = @result unless @error_message
                    flash[:error] = @error_message if @error_message
                    if @error_backtrace
                      flash[:alert] = "<button class='close show_hide' type='button'>⇕</button><pre>#{@error_backtrace}</pre>".html_safe
                    end
                    redirect_back(fallback_location: fallback_location)
                  }
                  format.js   {
                    render json: {
                      result: @error_message || @result,
                      error: {
                        message:    @error_message,
                        backtrace:  (@error_backtrace and "<button class='close show_hide' type='button'>⇕</button><pre>#{@error_backtrace}</pre>".html_safe)
                      }.compact
                    }
                  }
                end
              else
                respond_to do |format|
                  format.html {
                    # render @action.template_name
                    flash[:error] = "Не найдено действия для выполнения"
                    redirect_back(fallback_location: fallback_location)
                  }
                  format.js   {
                    render json: {
                      error: {
                        message: "Не найдено действия для выполнения"
                      }
                    }
                  }
                end
              end

            end
          end
        end

        register_instance_option :link_icon do
          'fa fa-magic'
        end

        register_instance_option :statistics? do
          false
        end

        register_instance_option :http_methods do
          [:get, :post]
        end
      end
    end
  end
end


module RailsAdmin
  module Config
    module Actions
      class SpecifiedActionsForCollection < RailsAdmin::Config::Actions::SpecifiedActions
        RailsAdmin::Config::Actions.register(self)

        # Is the action acting on the root level (Example: /admin/contact)
        register_instance_option :root? do
          false
        end

        register_instance_option :collection? do
          true
        end

        register_instance_option :member do
          false
        end

        register_instance_option :route_fragment do
          'specified_actions'
        end

        register_instance_option :template_name do
          'specified_actions'
        end

      end
    end
  end
end


module RailsAdmin
  module Config
    module Actions
      class SpecifiedActionsForMember < RailsAdmin::Config::Actions::SpecifiedActions
        RailsAdmin::Config::Actions.register(self)

        # Is the action acting on the root level (Example: /admin/contact)
        register_instance_option :root? do
          false
        end

        register_instance_option :collection? do
          false
        end

        register_instance_option :member do
          true
        end

        register_instance_option :route_fragment do
          'specified_actions'
        end

        register_instance_option :template_name do
          'specified_actions'
        end

      end
    end
  end
end
