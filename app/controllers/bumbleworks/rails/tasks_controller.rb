class Bumbleworks::Rails::TasksController < BumbleworksController
  helper Bumbleworks::Rails::ApplicationHelper
  before_filter :load_and_authorize_task, :except => :index

  def index
    @available_tasks = current_user.available_tasks
    @claimed_tasks = current_user.claimed_tasks
  end

  def complete
    if @task.claimant == current_user.claim_token
      @task.complete(params)
      flash[:notice] = 'Task completed!'
      redirect_to tasks_path
    else
      flash[:error] = 'You cannot complete a task not claimed by you'
      redirect_to entity_task_path @task
    end
  rescue Bumbleworks::Task::NotCompletable => e
    flash[:error] = e.message
    redirect_to entity_task_path @task
  end

  def claim
    current_user.claim(@task)
    redirect_to entity_task_path @task
  rescue Bumbleworks::Task::UnauthorizedClaimAttempt,
         Bumbleworks::Task::AlreadyClaimed => e
    flash[:error] = e.message
    redirect_to entity_task_path @task
  end

  def release
    current_user.release(@task)
  rescue Bumbleworks::User::UnauthorizedReleaseAttempt
    flash[:error] = "You do not currently have a lock on this task"
  ensure
    redirect_to entity_task_path @task
  end

  def load_and_authorize_task
    @task = Bumbleworks::Task.find_by_id(params[:id])
    render_unauthorized and return unless current_user.has_role? @task.role
  rescue Bumbleworks::Task::MissingWorkitem => e
    flash[:error] = "Cannot find task: #{params[:id]}"
    redirect_to '/'
  end

  def entity_task_path(task)
    task_path(task.id)
  end
end