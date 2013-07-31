# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get '/request_document', to: 'document_request#index'
get '/request_document/test', to: 'document_request#test'
