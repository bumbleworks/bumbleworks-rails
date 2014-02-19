## Bumbleworks::Rails

A Rails Engine to assist with integrating [Bumbleworks](http://github.com/bumbleworks/bumbleworks) into a Rails app.

## Installation

Add this line to your application's Gemfile:

    gem 'bumbleworks-rails'

## Usage

There are quite a few ways to use this - the most common, if you're using Bumbleworks in a Rails app, would be to add the "tasks" resource to your routes:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # ...
  scope :module => 'bumbleworks/rails' do
    resources :tasks do
      member do
        post 'complete'
        post 'claim'
        post 'release'
      end
      collection do
        get 'launch'
      end
    end
  end
  # ...
end
```

and to include Bumbleworks::User in your user model:

```ruby
# app/models/user.rb
class User < ActiveRecord::Base
  include Bumbleworks::User
  # ...
end
```

More instructions to come.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
