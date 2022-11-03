Rails.application.routes.draw do
  
   root 'sessions#welcome'

   resources :users, only: [:new, :create]

   get 'patches', to: 'patches#index'
  get 'patches/new', to: 'patches#new'
  post 'patches', to: 'patches#create'
  delete 'patches', to: 'patches#destroy'


   get 'login', to: 'sessions#new'
   post 'login', to: 'sessions#create'
   delete 'logout', to: 'sessions#destroy'

   get 'users', to: 'sessions#users'
   post 'add_user', to: 'sessions#add_user'
   post 'add_role', to: 'sessions#add_role'
   get 'users/:id', to: 'sessions#add_user_role', as: 'user'
   post 'users/:id', to: 'sessions#post_user_role', as: 'user/id'
   
   get 'welcome', to: 'sessions#welcome'
   get 'authorized', to: 'sessions#page_requires_login'

   get 'create_group', to: 'sessions#create_group'
   post 'create_group', to: 'sessions#send_group'
   get 'visit_group', to: 'sessions#find_group'
   post 'visit_group', to: 'sessions#access_group'

   get 'oracle', to: 'sessions#oracle'
   post 'oracle_state', to: 'sessions#add_state_oracle'
   post 'oracle_transition', to: 'sessions#add_transition_oracle'
   post 'oracle_role', to: 'sessions#add_transition_role'
   post 'delete_oracle_state', to: 'sessions#delete_oracle_state'
   post 'delete_oracle_transition', to: 'sessions#delete_oracle_transition'

   get 'state', to: 'sessions#state'
   post 'state_initial', to: 'sessions#set_state_initial'
   post 'state_final', to: 'sessions#set_state_final'
   post 'add_patch', to: 'sessions#add_patch'
   post 'transition_patch', to: 'sessions#transition_patch'

   get 'devices', to: 'devices#index'
   get 'add_device', to: 'devices#add_device'
   post 'devices', to: 'devices#create'
   get '/devices/:id', to: 'devices#show', as: 'device'
   get '/devices/:id/add_software', to: 'softwares#add_software', as: 'device/id'
   post '/devices/:id/add_software', to: 'softwares#create', as:'device/id/createsoftware'
   get '/devices/:id/view_patches', to: 'softwares#view_patches', as: 'device/id/view_patches'
   
   post '/devices/:id', to: 'devices#apply_patch', as: 'device/id/apply'
   post '/devices/:id/transition', to: 'devices#transition', as: 'device/id/transition'

end