Rails.application.routes.draw do
  root 'dns_entries#list'
  get 'servers', to: 'servers#list'
  get 'dns-entries', to: 'dns_entries#list'
  delete 'servers/:id', to: 'servers#remove_from_rotation'
  put 'servers', to: 'servers#add_to_rotation'
  Healthcheck.routes(self)
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
