describe Bumbleworks::Rails::TasksHelper do
  let(:task) {
    double(Bumbleworks::Task, {
      :nickname => 'chew_on_quandary',
      :entity => Fridget.new(5),
      :has_entity? => true,
      :id => '12345-spaghetti-hats'
    })
  }

  describe '#task_name' do
    it 'returns task #to_s if no translation' do
      expect(helper.task_name(task)).to eq task.to_s
    end

    it 'returns translation if exists' do
      allow(task).to receive(:nickname).and_return('shave_calves')
      expect(helper.task_name(task)).to eq('Calf Shaving is Fun')
    end

    it 'provides entity for interpolation' do
      allow(task.entity).to receive(:to_param).and_return('my feet')
      allow(task).to receive(:nickname).and_return('iron_feet')
      expect(helper.task_name(task)).to eq('Ouch, that hurts my feet')
    end
  end

  describe '#render_task_partial' do
    it 'does not render anything if no custom partial exists' do
      allow(task).to receive(:nickname).and_return('oolo')
      expect(helper.render_task_partial(task)).to be_nil
    end

    it 'renders non-entity-specific custom partial if no entity' do
      allow(task).to receive(:has_entity?).and_return(false)
      expect(helper).to receive(:render).
        with({
          :template => 'custom/_chew_on_quandary',
          :prefixes => ['bumbleworks/tasks']
        }).
        and_return('pretend')
      expect(helper.render_task_partial(task)).to eq('pretend')
    end

    it 'renders entity-specific custom partial' do
      expect(helper).to receive(:render).
        with({
          :template => 'custom/_chew_on_quandary',
          :prefixes => ['fridgets/tasks', 'bumbleworks/tasks']
        }).
        and_return('pretend')
      expect(helper.render_task_partial(task)).to eq('pretend')
    end
  end

  context 'task url helpers' do
    let(:main_app) { double('main_app') }

    before(:each) do
      allow(helper).to receive(:main_app).and_return(main_app)
    end

    describe '#entity_task_url' do
      it 'returns an entity-specific url for the task' do
        allow(main_app).to receive(:task_url).
          with(:entity_type => 'fridgets', :entity_id => 5, :other => :things, :id => task.id).
          and_return(:the_url)
        expect(helper.entity_task_url(task, :other => :things)).to eq(:the_url)
      end
    end

    describe '#entity_tasks_url' do
      it 'returns an entity-specific task index' do
        allow(main_app).to receive(:tasks_url).
          with(:entity_type => 'fridgets', :entity_id => 5, :other => :things).
          and_return(:the_url)
        expect(helper.entity_tasks_url(task.entity, :other => :things)).to eq(:the_url)
      end
    end

    describe '#entity_task_path' do
      it 'returns a path-only entity task url' do
        allow(helper).to receive(:entity_task_url).
          with(task.entity, :other => :things, :only_path => true).
          and_return(:the_url)
        expect(helper.entity_task_path(task.entity, :other => :things)).to eq(:the_url)
      end
    end

    describe '#entity_tasks_path' do
      it 'returns a path-only entity tasks url' do
        allow(helper).to receive(:entity_tasks_url).
          with(task.entity, :other => :things, :only_path => true).
          and_return(:the_url)
        expect(helper.entity_tasks_path(task.entity, :other => :things)).to eq(:the_url)
      end
    end
  end
end