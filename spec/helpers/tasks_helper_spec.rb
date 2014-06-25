describe Bumbleworks::Rails::TasksHelper do
  let(:task) {
    double(Bumbleworks::Task, {
      :nickname => 'chew_on_quandary',
      :entity => Fridget.new(5),
      :has_entity? => true
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
end