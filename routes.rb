resources :feature_types, :member => { :summary => :get }, :has_many => [ :articles, :features, :feature_types ]
resources :features, :has_many => [ :articles ]
resources :makes, :has_many => [ :articles, :features, :models, :comments, :reviews, :watchings ]
resources :manufacturers, :has_many => [ :articles, :costs, :makes, :offers, :comments, :reviews, :themes, :watchings ]
resources :models, :has_many => [ :articles, :features, :products, :comments, :reviews, :watchings ]
resources :offers, :member => { :edit_products => :get, :update_products => :put }, :has_many => [ :articles, :products ]
resources :pages, :has_many => [ :articles ]
resources :prices
resources :products, :collection => { :search => :get, :results => :get, :compare => :get },
                     :has_many => [ :articles, :costs, :features, :offers, :prices, :comments, :reviews, :watchings ]
resources :quote_requests
user_quote_requests "/users/:user_id/quote_requests", :controller => 'quote_requests', :action => 'index'
new_user_quote_request "/users/:user_id/quote_requests", :controller => 'quote_requests', :action => 'new', :method => :post
resources :vendors, :has_many => [ :articles, :offers, :prices, :quote_requests, :comments, :reviews, :themes, :watchings ]
