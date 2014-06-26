require 'rails/generators'
require 'rails/generators/base'

module Bumbleworks
  module Rails
    class InstallGenerator < ::Rails::Generators::Base
      attr_reader :storage_type, :storage_config_path,
        :storage, :storage_options

      STORAGE_TYPES = ['Sequel', 'Redis', 'Hash']
      STORAGE_CONFIG_PATH = "config/bumbleworks_storage.yml"
      SEQUEL_TABLE_NAME = "bumbleworks_documents"
      QUESTIONS = {
        :which_storage => "Which storage will you be using?",
        :storage_config_path => "Where do you want your storage configuration file to live?",
        :sequel_table_name => "What database table name do you want Bumbleworks to use?"
      }

      class_option :storage_type, :type => :string,
        :desc => "Which storage type to use (#{STORAGE_TYPES.join(', ')})"
      class_option :table_name, :type => :string,
        :desc => "Table name for key-value store (Sequel storage only)"
      class_option :storage_config_path, :type => :string,
        :desc => "Where your storage config file is (or should be created)"

      source_root File.expand_path("../templates", __FILE__)

      desc "Installs Bumbleworks into a Rails app"

      def introduction
        say <<-INTRODUCTION

Let's install Bumbleworks into your Rails app!

        INTRODUCTION
      end

      def check_storage_type
        @storage_type = if options[:storage_type]
          unless STORAGE_TYPES.include?(options[:storage_type])
            say "Storage type specified must be one of: #{STORAGE_TYPES.join(', ')}"
            exit 1
          end
          options[:storage_type].underscore
        else
          ask(QUESTIONS[:which_storage], :limited_to => STORAGE_TYPES).underscore
        end
      end

      def add_storage_gem_to_gemfile
        unless storage_type == 'hash'
          create_file 'Gemfile', :skip => true
          add_source 'https://rubygems.org'
          gem "bumbleworks-#{storage_type}"
        end
      end

      def ask_for_table_name
        if storage_type == 'sequel'
          unless @table_name = options[:table_name]
            @table_name = ask("#{QUESTIONS[:sequel_table_name]} [#{SEQUEL_TABLE_NAME}]")
            @table_name = SEQUEL_TABLE_NAME if @table_name.blank?
          end
          @storage_options = { 'sequel_table_name' => options[:table_name] }
        end
      end

      def copy_storage_config_file
        unless storage_type == 'hash'
          unless @storage_config_path = options[:storage_config_path]
            @storage_config_path = ask("#{QUESTIONS[:storage_config_path]} [#{STORAGE_CONFIG_PATH}]")
            @storage_config_path = STORAGE_CONFIG_PATH if @storage_config_path.blank?
          end

          template "config/storages/#{storage_type}.yml", storage_config_path
        end
      end

      def copy_initializer
        template 'config/initializers/bumbleworks.rb',
          'config/initializers/bumbleworks.rb'
      end

      def copy_bumbleworks_directory
        directory 'lib'
      end

      def copy_locale
        copy_file "config/locales/bumbleworks.en.yml",
          "config/locales/bumbleworks.en.yml"
      end

      def add_routes
        insert_into_file 'config/routes.rb', :after => /\.routes\.draw do\s*$/ do
          File.read(find_in_source_paths('config/routes.rb'))
        end
      end

      def add_task_helper_to_application_controller
        insert_into_file 'app/controllers/application_controller.rb',
          :after => "protect_from_forgery with: :exception\n" do <<-RUBY

  helper Bumbleworks::Rails::TasksHelper
          RUBY
        end
      end

      def farewell
        say <<-FAREWELL

We're done!  Remember to run `rake bumbleworks:bootstrap` whenever you change
process definitions or participant registration.  Enjoy using bumbleworks!

        FAREWELL
      end

    protected

      def storage
        case storage_type
          when 'hash'
            '{}'
          when 'redis'
            'Redis.new(storage_config)'
          when 'sequel'
            'Sequel.connect(storage_config)'
        end
      end
    end
  end
end