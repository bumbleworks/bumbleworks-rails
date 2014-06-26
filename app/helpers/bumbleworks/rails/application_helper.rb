module Bumbleworks
  module Rails
    module ApplicationHelper
      def method_missing method, *args, &block
        if method_is_main_app_url_helper?(method)
          main_app.send(method, *args)
        else
          super
        end
      end

      def respond_to?(method)
        if method_is_main_app_url_helper?(method)
          true
        else
          super
        end
      end

      def method_is_main_app_url_helper?(method)
        method.to_s =~ /(_path|_url)$/ && main_app.respond_to?(method)
      end
    end
  end
end
