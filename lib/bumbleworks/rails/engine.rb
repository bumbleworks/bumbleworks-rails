require 'bumbleworks'

module Bumbleworks
  module Rails
    class Engine < ::Rails::Engine
      isolate_namespace Bumbleworks::Rails

      rake_tasks do
        require 'bumbleworks/rake_tasks'
      end
    end
  end
end
