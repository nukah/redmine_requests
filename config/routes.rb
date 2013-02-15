# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

match '/queries/:project_id', :to => "queries#set_default", :via => :post, :as => 'set_default_query'
root :to => "projects#index", :as => "home"
