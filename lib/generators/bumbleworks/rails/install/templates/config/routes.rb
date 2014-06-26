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

  mount Bumbleworks::Gui::RackApp => 'bw'
