class Bumbleworks::Rails::TasksController < BumbleworksController
  before_filter :load_and_authorize_task, :except => :index
  before_filter :load_entity

  def show
    render :prefixes => template_prefixes
  end

  def index
    [:available_tasks, :claimed_tasks].each do |category|
      tasks = current_user.send(category)
      tasks = tasks.for_entity(@entity) if @entity
      instance_variable_set("@#{category}", tasks)
    end
    render :prefixes => template_prefixes
  end

  def complete
    if @task.claimant == current_user.claim_token
      @task.complete(params[:task] || {})
      flash[:notice] = I18n.t('bumbleworks.tasks.completed')
      redirect_to tasks_path
    else
      flash[:error] = I18n.t('bumbleworks.tasks.unclaimed_complete_attempt')
      redirect_to entity_task_path @task
    end
  rescue Bumbleworks::Task::NotCompletable => e
    flash[:error] = e.message
    redirect_to entity_task_path @task
  end

  def claim
    current_user.claim(@task)
  rescue Bumbleworks::User::UnauthorizedClaimAttempt,
         Bumbleworks::Task::AlreadyClaimed => e
    flash[:error] = e.message
  ensure
    redirect_to entity_task_path @task
  end

  def release
    current_user.release(@task)
  rescue Bumbleworks::User::UnauthorizedReleaseAttempt
    flash[:error] = I18n.t('bumbleworks.tasks.unauthorized_release_attempt')
  ensure
    redirect_to entity_task_path @task
  end

protected

  def template_prefixes
    prefixes = _prefixes.prepend("bumbleworks/tasks")
    prefixes.unshift("#{@entity.class.entity_type.pluralize}/tasks") if @entity
    prefixes
  end

  def load_entity
    if @task
      @entity = @task.entity if @task.has_entity?
    elsif params[:entity_type].present? && params[:entity_id].present?
      klass = params[:entity_type].classify.constantize
      render_404 and return unless Bumbleworks.entity_classes.include?(klass)
      @entity = klass.first_by_identifier(params[:entity_id])
      render_404 and return unless @entity
    end
  rescue NameError => e
    render_404
  end

  def load_and_authorize_task
    @task = Bumbleworks::Task.find_by_id(params[:id])
    render_unauthorized and return unless current_user.has_role? @task.role
  rescue Bumbleworks::Task::MissingWorkitem => e
    flash[:error] = I18n.t('bumbleworks.tasks.not_found', :task_id => params[:id])
    redirect_to '/'
  end
end