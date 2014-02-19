Rails.application.routes.draw do

  mount Bumbleworks::Rails::Engine => "/bumbleworks/rails"
end
