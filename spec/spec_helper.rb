require 'simplecov'
SimpleCov.start do
  add_filter "/spec/dummy/"
end

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require 'rspec/rails'

FAKE_DATABASE = {}

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.before(:each) do
    FAKE_DATABASE.keys.each do |key|
      FAKE_DATABASE[key] = []
    end
  end
end