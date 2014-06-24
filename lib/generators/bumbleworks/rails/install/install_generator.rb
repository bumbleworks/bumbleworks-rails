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
        :storage_config_exists => "Do you already have a storage configuration .yml?",
        :storage_config_path => "Where is your config file located?",
        :sequel_table_name => "What database table name do you want Bumbleworks to use?"
      }

      source_root File.expand_path("../templates", __FILE__)

      desc "Installs Bumbleworks into a Rails app"

      def introduction
        say <<-INTRODUCTION

Thank you for installing Bumbleworks into your Rails app!  Just a few quick
questions...

        INTRODUCTION
      end

      def ask_for_storage_type
        @storage_type = ask(QUESTIONS[:which_storage], :limited_to => STORAGE_TYPES).underscore
      end

      def remind_about_storage_gem
        unless storage_type == 'hash'
          say <<-GEM_REMINDER

Remember to add the following to your Gemfile if you haven't already:
  gem 'bumbleworks-#{storage_type}'

          GEM_REMINDER
        end
      end

      def ask_for_table_name
        if storage_type == 'sequel'
          table_name = ask("#{QUESTIONS[:sequel_table_name]} [#{SEQUEL_TABLE_NAME}]")
          table_name = SEQUEL_TABLE_NAME if table_name.blank?
          @storage_options = { 'sequel_table_name' => table_name }
        end
      end

      def ask_for_storage_config_path
        unless storage_type == 'hash'
          has_config_file = ask("#{QUESTIONS[:storage_config_exists]} (y/n) [n]",
            :limited_to => ['y', 'n', '']) == 'y'
          if has_config_file
            @storage_config_path = ask("#{QUESTIONS[:storage_config_path]} [#{STORAGE_CONFIG_PATH}]")
          end
          @storage_config_path = STORAGE_CONFIG_PATH if storage_config_path.blank?

          copy_storage_config_file unless has_config_file
        end
      end

      def copy_initializer
        template 'config/initializers/bumbleworks.rb',
          'config/initializers/bumbleworks.rb'
      end

      def copy_bumbleworks_directory
        directory 'lib'
      end

      def farewell
        say <<-FAREWELL

You're done!  Remember to run `rake bumbleworks:bootstrap` whenever you change
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

      def copy_storage_config_file
        template "config/storages/#{storage_type}.yml", storage_config_path
      end
    end
  end
end