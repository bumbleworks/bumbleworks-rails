require 'bumbleworks/gui'

Rails.application.routes.draw do
  scope :module => 'bumbleworks/rails' do
    scope '(:entity_type/:entity_id)' do
      resources :tasks, :only => [:index, :show] do
        member do
          post 'complete'
          post 'claim'
          post 'release'
        end
      end
    end
  end

  resources :silvo_blooms
  resources :fridgets

  mount Bumbleworks::Gui::RackApp => 'bw'

  root 'bumbleworks/rails/tasks#index'
end
