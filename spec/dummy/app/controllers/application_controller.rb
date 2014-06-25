class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper Bumbleworks::Rails::TasksHelper

  helper_method :current_user

  def current_user
    @current_user ||= User.new('scotch', ['cop'])
  end
end
