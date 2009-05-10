class Offer < ActiveRecord::Base
  acts_as_resource :group => Proc.new { |offer| offer.offer_provider.group }
  
  belongs_to :offer_provider, :polymorphic => true
  has_and_belongs_to_many :products
  has_attached_file :image, Configuration.default_image_options
  has_enumeration :offer_type
  has_many_articles
  has_localized :name, :description

  validates_presence_of :name
  validates_uniqueness_of :code, :allow_nil => true
  validates_attachment_size :image, Configuration.default_image_size_options
  
  searches_on :name, :code
  
  def self.random(offer_provider = nil)
    if offer_provider
      conditions = { :offer_provider_type => offer_provider.class.to_s, :offer_provider_id => offer_provider.id }
      Offer.first(:conditions => conditions, :offset => rand(Offer.count(:conditions => conditions)))
    else
      Offer.first(:offset => rand(Offer.count))
    end
  end
end
