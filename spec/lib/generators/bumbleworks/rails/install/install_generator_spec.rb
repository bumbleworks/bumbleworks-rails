require "generators/bumbleworks/rails/install/install_generator"

describe Bumbleworks::Rails::InstallGenerator do
  destination Rails.root.join('..', '..', 'tmp', 'generated')

  before(:each) do
    prepare_destination
    mkdir_p destination_root.join('app', 'controllers')
    mkdir_p destination_root.join('config')
    File.open(destination_root.join('app', 'controllers', 'application_controller.rb'), 'w') do |f|
      f.puts('protect_from_forgery with: :exception')
    end
    File.open(destination_root.join('config', 'routes.rb'), 'w') do |f|
      f.puts('.routes.draw do')
    end
  end

  shared_examples_for "an install generator" do |options|
    it "installs and configures files" do
      generator_arguments = options.map { |k, v| "--#{k}=#{v}" }
      run_generator generator_arguments
      structure = GeneratorHelpers.structure(options)
      expect(destination_root).to have_structure &structure
    end
  end

  context "with Hash storage" do
    it_behaves_like 'an install generator', { :storage_type => 'Hash' }
  end

  context "with Redis storage" do
    it_behaves_like 'an install generator', {
      :storage_type => 'Redis',
      :storage_config_path => 'config/bumbleworks_storage.yml'
    }
  end

  context "with Sequel storage" do
    it_behaves_like 'an install generator', {
      :storage_type => 'Sequel',
      :storage_config_path => 'config/bumbleworks_storage.yml',
      :table_name => 'snooze_fudges'
    }
  end

  context "with custom config path location" do
    it_behaves_like 'an install generator', {
      :storage_type => 'Redis',
      :storage_config_path => 'apples/queens.yml',
    }
  end
end