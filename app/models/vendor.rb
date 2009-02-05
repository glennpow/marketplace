class Vendor < ActiveRecord::Base
  acts_as_resource :group => { :through => :organization }
  acts_as_organizable
  
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
  
  # attr_accessor :distance
  # 
  # acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude
  # 
  # def latitude
  #   self.organization && self.organization.address ? self.organization.address.latitude : nil
  # end
  # 
  # def longitude
  #   self.organization && self.organization.address ? self.organization.address.longitude : nil
  # end
end
