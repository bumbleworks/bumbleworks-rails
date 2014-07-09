module Bumbleworks
  module Rails
    module TasksHelper
      def render_task_partial(task, options = {})
        options[:prefixes] = ["bumbleworks/tasks"]
        options[:prefixes].unshift("#{task.entity.class.entity_type.pluralize}/tasks") if task.has_entity?
        template = "custom/_#{task.nickname}"
        if lookup_context.exists?(template, options[:prefixes])
          options[:template] = template
          render options
        end
      end

      def task_name(task)
        entity = task.has_entity? ? task.entity.to_param : nil
        I18n.t(task.nickname, :entity => entity, :scope => 'bumbleworks.tasks.names', :default => task.to_s)
      end

      def entity_task_url(task, options = {})
        if task.has_entity?
          options[:entity_type] = task.entity.class.entity_type.pluralize
          options[:entity_id] = task.entity.identifier
        end
        main_app.task_url(options.merge(:id => task.id))
      end

      def entity_task_path(task, options = {})
        entity_task_url(task, options.merge(:only_path => true))
      end

      def entity_tasks_url(entity, options = {})
        if entity
          options[:entity_type] = entity.class.entity_type.pluralize
          options[:entity_id] = entity.identifier
        end
        main_app.tasks_url(options)
      end

      def entity_tasks_path(entity, options = {})
        entity_tasks_url(entity, options.merge(:only_path => true))
      end
    end
  end
end
