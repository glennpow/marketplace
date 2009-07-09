ActionController::Routing::Routes.draw do |map|
  map.resources :costs
  map.resources :features, :member => { :summary => :get }, :has_many => [ :articles, :features ]
  map.resources :makes, :has_many => [ :articles, :features, :models, :comments, :reviews, :watchings ]
  map.resources :manufacturers, :has_many => [ :articles, :costs, :makes, :offers, :comments, :reviews, :themes, :watchings ]
  map.resources :models, :has_many => [ :articles, :features, :products, :comments, :reviews, :watchings ]
  map.resources :offers, :member => { :edit_products => :get, :update_products => :put }, :has_many => [ :articles, :products ]
  map.resources :pages, :has_many => [ :articles ]
  map.resources :prices
  map.resources :products, :collection => { :search => :get, :results => :get, :compare => :get },
                       :has_many => [ :articles, :costs, :features, :offers, :prices, :comments, :reviews, :watchings ]
  map.resources :orders, :has_many => [ :order_line_items ]
  map.cart "/cart", :controller => 'orders', :action => 'current'
  map.checkout "/checkout", :controller => 'orders', :action => 'checkout'
  map.purchase "/purchase", :controller => 'orders', :action => 'purchase'
  map.add_to_cart "/add_to_cart/:price_id", :controller => 'orders', :action => 'add_to_cart'
  map.resources :order_line_items
  map.resources :order_transactions
  map.resources :quote_requests
  map.user_quote_requests "/users/:user_id/quote_requests", :controller => 'quote_requests', :action => 'index'
  map.new_user_quote_request "/users/:user_id/quote_requests", :controller => 'quote_requests', :action => 'new', :method => :post
  map.resources :vendors, :has_many => [ :articles, :offers, :prices, :quote_requests, :comments, :reviews, :themes, :watchings ]
end