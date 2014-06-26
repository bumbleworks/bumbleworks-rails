module GeneratorHelpers
  class << self
    def structure(options = {})
      Proc.new {
        directory "app" do
          directory "controllers" do
            file "application_controller.rb" do
              contains "helper Bumbleworks::Rails::TasksHelper"
            end
          end
        end
        directory "config" do
          directory "initializers" do
            file "bumbleworks.rb" do
              contains "Bumbleworks.config"
              if options[:storage_type] == 'Hash'
                contains '{}'
              else
                contains options[:storage_type]
                contains options[:table_name] || ''
              end
            end
          end
          directory "locales" do
            file "bumbleworks.en.yml"
          end
          file "routes.rb" do
            contains "bumbleworks/rails"
          end
        end
        directory "lib" do
          directory "bumbleworks" do
            directory "processes"
            directory "participants"
            directory "tasks"
            file "participants.rb" do
              contains "Bumbleworks.register_participants"
            end
          end
        end
        unless options[:storage_type] == 'Hash'
          file options[:storage_config_path] do
            contains "Using the #{options[:storage_type]}"
          end
        end
      }
    end
  end
end