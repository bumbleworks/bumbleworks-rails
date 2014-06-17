require 'bumbleworks'

module Bumbleworks
  module Rails
    class Engine < ::Rails::Engine
      isolate_namespace Bumbleworks::Rails
    end
  end
end
