# RailsAdminSpecifiedActions

Custom actoions for RailsAdmin

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails_admin_specified_actions'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails_admin_specified_actions

## Usage

Add the sort_embedded action for each model or only for models you need

```ruby
    RailsAdmin.config do |config|
      config.actions do
        ...
        specified_actions do
          # You can add actions like this

          require_relative 'rails_admin_specified_actions'
          RailsAdminSpecifiedActions.root_actions(self)

          # also you can add actions like this:
          config.action :count do
            object do
              User
            end
          end # will perform `action_name` for `object`: 'User.count'
        end # for root actions
        specified_actions_for_collection # for collections actions
        specified_actions_for_member # for member actions
        ...
      end
    end
```

For root actions you can create config/initializers/rails_admin_specified_actions_root.rb:
```ruby
module RailsAdminSpecifiedActions

  class << self

    def root_actions(config)
      config.action :some_root_action do
        process_block do
          proc { |obj, args|
            # `obj` will be nil
            Rails.cache.clear # or some other global action
          }
        end
      end
      config.action :some_root_action_with_obj do
        process_block do
          proc { |obj, args|
            # `obj` will be User
            obj.delete_all # delete them all
          }
        end
        object do
          Page
        end
      end
    end

  end

end

```
or something like this.


For collection and member actions actions:
In rails_admin block:

```ruby
  rails_admin do
    ...
    specified_actions_for_collection do
      action :count, :collection do
        process_block do
          proc { |model, args|
            model.all.count
          }
        end
      end
    end
    ...
  end
```
or

```ruby
  rails_admin do
    ...
    specified_actions_for_member do
      action :touch
    end
    ...
  end
```
or both.

Options for action:

| Option name              | Description                                                      | Default value |
|--------------------------|------------------------------------------------------------------|---------------|
| label                    | Displayed label                                                  | as name       |
| button-text              | Text on action button                                            | as name       |
| process_block            | Proc for action or action name for \__send__()                   | nil           |
| target                   | :root, :collection or :member                                    | nil           |
| ajax                     | If you don`t need reload page                                    | false         |
| threaded                 | Create new thread for this action if that can take a long time   | false         |
| can_view_error_backtrace | If you want show error code backtrace. Perhaps, only for admins. | 'only admin'  |
| can_view_error_message   | If you want show detailed errors message                         | false         |
| args                     | Hash of possible arguments (and their types) for action          | {}            |

Possible argument types (and field types):


| Type                     | Field                                                            |
|--------------------------|------------------------------------------------------------------|
| nil                      | String (`text_field` method)                                     |
| :string                  | String (`text_field` method)                                     |
| :boolean                 | Boolean/Checkbox field (`check_box` method)                      |
| :toggle                  | Boolean/Checkbox field (`check_box` method)                      |


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/red-rocks/rails_admin_specified_actions.
