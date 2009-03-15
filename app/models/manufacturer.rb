class Manufacturer < ActiveRecord::Base
  acts_as_resource :group => { :through => :organization }
  acts_as_organizable
  
  has_many :makes, :order => 'name ASC', :dependent => :destroy
  has_many :models, :through => :makes, :order => 'name ASC', :uniq => true
  # FIXME - has_many-through-through associations don't work
  #has_many :products, :through => :models, :order => 'name ASC', :uniq => true
  has_many :costs, :dependent => :destroy
  has_many :offers, :as => :offer_provider, :dependent => :destroy
  
  def name
    self.organization.name
  end

  def available_makes
    self.makes.select { |make| make.available? }
  end
  
  def available_models
    self.models.select { |model| model.available? }
  end
  
  def products
    self.models.collect { |model| model.products }.flatten.uniq
  end
  
  def available_products
    self.products.select { |product| product.available? }
  end
end
