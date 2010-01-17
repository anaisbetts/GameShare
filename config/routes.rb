ActionController::Routing::Routes.draw do |map|
  map.resources :groups

  map.connect ':controller/:action/:id.:format'
  map.root :controller => "groups"
end
