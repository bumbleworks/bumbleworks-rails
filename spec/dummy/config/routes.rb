Rails.application.routes.draw do
  root 'bumbleworks/rails/tasks#index'

  scope :module => 'bumbleworks/rails' do
    resources :tasks do
      member do
        post 'complete'
        post 'claim'
        post 'release'
      end
    end
  end

  mount Bumbleworks::Gui::RackApp => 'bw'
end
