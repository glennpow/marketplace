class Vendor < ActiveRecord::Base
  acts_as_resource :group => { :through => :organization }
  acts_as_organizable :dependent => :destroy
  
  has_many :prices, :dependent => :destroy
  has_many :products, :through => :prices
  has_many :offers, :as => :offer_provider, :dependent => :destroy
  has_many :quote_requests, :order => 'created_at DESC', :dependent => :destroy
  
  def name
    self.organization.name
  end
  
  def available_products
    self.products.select { |product| product.available? }
  end
end
