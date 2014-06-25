require 'rake'

describe Bumbleworks::Rails::Engine do
  describe '.load_tasks' do
    it "loads bumbleworks rake tasks" do
      expect(Rake::Task.task_defined?('bumbleworks:bootstrap')).to be_falsy
      described_class.load_tasks
      expect(Rake::Task.task_defined?('bumbleworks:bootstrap')).to be_truthy
    end
  end
end
