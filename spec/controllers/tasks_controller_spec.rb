describe Bumbleworks::Rails::TasksController do
  let(:task) {
    double(Bumbleworks::Task, {
      :role => 'cop',
      :id => 'werk',
      :entity => Fridget.new(5),
      :has_entity? => true
    })
  }

  before(:each) do
    allow(Bumbleworks::Task).to receive(:find_by_id).
      with('152').and_return(task)
  end

  shared_examples_for "a task action" do |method, action|
    it "renders unauthorized if user does not have role" do
      allow(task).to receive(:role).and_return('gubbenor')
      self.send(method, action, :id => 152)
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to eq(I18n.t('bumbleworks.unauthorized'))
    end

    it "redirects if task missing" do
      allow(Bumbleworks::Task).to receive(:find_by_id).
        with('152').and_raise(Bumbleworks::Task::MissingWorkitem)
      self.send(method, action, :id => 152)
      expect(flash[:error]).to eq(I18n.t('bumbleworks.tasks.not_found', :task_id => '152'))
      expect(response).to redirect_to '/'
    end
  end

  describe '#show' do
    it_behaves_like 'a task action', :get, :show

    it 'renders specific show template if exists for entity' do
      get :show, :id => 152
      expect(response).to render_template('fridgets/tasks/show')
    end

    it 'renders generic show template if entity has no specific one' do
      allow(task).to receive(:entity).and_return(SilvoBloom.new(3))
      get :show, :id => 152
      expect(response).to render_template('bumbleworks/rails/tasks/show')
    end

    it 'renders generic show template if task has no entity' do
      allow(task).to receive(:has_entity?).and_return(false)
      get :show, :id => 152
      expect(response).to render_template('bumbleworks/rails/tasks/show')
    end
  end

  describe '#complete' do
    it_behaves_like 'a task action', :post, :complete

    it 'completes the task if claimed by current_user' do
      allow(task).to receive(:claimant).and_return('scotch')
      expect(task).to receive(:complete).with('foo' => 'bar')
      post :complete, :id => 152, :task => { :foo => :bar }
      expect(flash[:notice]).to eq(I18n.t('bumbleworks.tasks.completed'))
      expect(response).to redirect_to(controller.entity_tasks_path(task.entity))
    end

    it 'does not complete the task if not claimed by current_user' do
      allow(task).to receive(:claimant).and_return('freezel')
      expect(task).not_to receive(:complete)
      post :complete, :id => 152, :task => { :foo => :bar }
      expect(flash[:error]).to eq(I18n.t('bumbleworks.tasks.unclaimed_complete_attempt'))
      expect(response).to redirect_to(controller.entity_task_path(task))
    end

    it 'does not complete the task if not completable' do
      allow(task).to receive(:claimant).and_return('scotch')
      expect(task).to receive(:complete).
        and_raise(Bumbleworks::Task::NotCompletable, "no way")
      post :complete, :id => 152, :task => { :foo => :bar }
      expect(flash[:error]).to eq("no way")
      expect(response).to redirect_to(controller.entity_task_path(task))
    end

    it 'does not complete the task if completion fails' do
      allow(task).to receive(:claimant).and_return('scotch')
      expect(task).to receive(:complete).
        and_raise(Bumbleworks::Task::CompletionFailed)
      post :complete, :id => 152, :task => { :foo => :bar }
      expect(response).to render_template('fridgets/tasks/show')
    end
  end

  describe '#claim' do
    it_behaves_like 'a task action', :post, :claim

    it 'claims the task if authorized and unclaimed' do
      expect(subject.current_user).to receive(:claim).with(task)
      post :claim, :id => 152
      expect(response).to redirect_to(controller.entity_task_path(task))
    end

    it 'does not claim the task if unauthorized' do
      allow(subject.current_user).to receive(:claim).with(task).
        and_raise(Bumbleworks::User::UnauthorizedClaimAttempt, "you can't")
      post :claim, :id => 152
      expect(flash[:error]).to eq("you can't")
      expect(response).to redirect_to(controller.entity_task_path(task))
    end

    it 'does not claim the task if already claimed' do
      allow(subject.current_user).to receive(:claim).with(task).
        and_raise(Bumbleworks::Task::AlreadyClaimed, "someone has it")
      post :claim, :id => 152
      expect(flash[:error]).to eq("someone has it")
      expect(response).to redirect_to(controller.entity_task_path(task))
    end
  end

  describe '#release' do
    it_behaves_like 'a task action', :post, :release

    it 'releases the task if current claimant' do
      expect(subject.current_user).to receive(:release).with(task)
      post :release, :id => 152
      expect(response).to redirect_to(controller.entity_task_path(task))
    end

    it 'does not release the task if not claimant' do
      allow(subject.current_user).to receive(:release).with(task).
        and_raise(Bumbleworks::User::UnauthorizedReleaseAttempt)
      post :release, :id => 152
      expect(flash[:error]).to eq(I18n.t('bumbleworks.tasks.unauthorized_release_attempt'))
      expect(response).to redirect_to(controller.entity_task_path(task))
    end
  end

  describe '#index' do
    [:available_tasks, :claimed_tasks].each do |task_type|
      it "exposes #{task_type} for current user" do
        allow(subject.current_user).to receive(task_type).
          and_return(:the_tasks)
        get :index
        expect(assigns(task_type)).to eq :the_tasks
      end

      it "filters #{task_type} by entity if provided" do
        finder = Bumbleworks::Task::Finder.new
        fridget = Fridget.new(5)
        allow(Fridget).to receive(:first_by_identifier).with('5').
          and_return(fridget)
        allow(subject.current_user).to receive(task_type).
          and_return(finder)
        allow(finder).to receive(:for_entity).
          with(fridget).and_return(:filtered_tasks)
        get :index, :entity_type => 'fridget', :entity_id => '5'
        expect(assigns(task_type)).to eq :filtered_tasks
      end
    end

    it 'renders 404 if given nonexistent entity type' do
      get :index, :entity_type => 'goof', :entity_id => 2
      expect(response).to have_http_status(:not_found)
    end

    it 'renders 404 if given nonexistent entity' do
      allow(Fridget).to receive(:first_by_identifier).with('3').
        and_return(nil)
      get :index, :entity_type => 'fridget', :entity_id => 3
      expect(response).to have_http_status(:not_found)
    end

    it 'renders 404 if entity class not registered with Bumbleworks' do
      Smoo = Class.new
      get :index, :entity_type => 'smoo', :entity_id => 2
      expect(response).to have_http_status(:not_found)
    end

    it 'renders generic index template if no entity' do
      get :index
      expect(response).to render_template('bumbleworks/rails/tasks/index')
    end

    it 'renders specific index template if exists for entity' do
      SilvoBloom.new(5)
      get :index, :entity_type => 'silvo_blooms', :entity_id => '5'
      expect(response).to render_template('silvo_blooms/tasks/index')
    end

    it 'renders generic index template if entity has no specific one' do
      Fridget.new(6)
      get :index, :entity_type => 'fridgets', :entity_id => '6'
      expect(response).to render_template('bumbleworks/rails/tasks/index')
    end
  end
end