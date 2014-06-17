module Bumbleworks
  module Rails
    module TasksHelper
      def task_name(task)
        entity = task.has_entity? ? task.entity.to_param : nil
        I18n.t(task.nickname, :entity => entity, :scope => 'task', :default => task.to_s)
      end
    end
  end
end
