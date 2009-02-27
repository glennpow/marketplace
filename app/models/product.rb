class Product < ActiveRecord::Base
  acts_as_resource :group => Proc.new { |product| product.model.group }
  acts_as_commentable
  acts_as_reviewable

  belongs_to :model
  has_one :make, :through => :model
  # FIXME - has_many-through-through associations don't work
  #has_one :manufacturer, :through => :make
  has_many_features :include => [ :model ]
  has_and_belongs_to_many :offers, :order => 'created_at DESC'
  has_many :prices, :dependent => :destroy, :order => 'created_at DESC'
  has_many :vendors, :through => :prices, :order => 'name ASC'
  has_attached_file :image, Configuration.default_image_options
  has_enumeration :production_status
  has_many_articles
  
  validates_presence_of :name, :description, :model
  validates_uniqueness_of :sku
  validates_attachment_size :image, Configuration.default_image_size_options
  
  searches_on :name, :description, :sku
  
  def manufacturer
    self.make.manufacturer
  end
  
  def full_name
    [ self.make.name, self.model.name, self.name ].join(' ')
  end
  
  def production_status_with_model
    self.production_status_without_model || self.model.production_status
  end
  alias_method_chain :production_status, :model
  
  def offers_with_offer_provider(offer_provider)
    self.offers.select { |offer| offer.offer_provider_type == offer_provider.class.to_s && offer.offer_provider_id == offer_provider.id }
  end
  
  def has_offer_with_offer_provider?(offer_provider)
    not self.offers.detect { |offer| offer.offer_provider_type == offer_provider.class.to_s && offer.offer_provider_id == offer_provider.id }.nil?
  end
  
  def price_for_vendor(vendor)
    self.prices.detect { |price| price.vendor_id == vendor.id }
  end
    
  def available?
    self.production_status_id == ProductionStatus[:available].id
  end
end
