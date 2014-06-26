class BumbleworksController < Bumbleworks::Rails::ApplicationController
  include Bumbleworks::Rails::TasksHelper

  def render_unauthorized
    render :text => I18n.t('bumbleworks.unauthorized'), :status => :unauthorized
  end

  def render_404
    render :text => 'page not found', :status => 404
  end
end
