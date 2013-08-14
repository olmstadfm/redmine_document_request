# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

# resources :document_request

# get '/request_document', to: 'document_request#'
get  '/document_request/new', to: 'document_request#new'
post '/document_request/create', to: 'document_request#create'
