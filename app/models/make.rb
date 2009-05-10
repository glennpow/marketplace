class Make < ActiveRecord::Base
  acts_as_resource :group => Proc.new { |make| make.manufacturer.group }
  acts_as_commentable
  acts_as_reviewable

  belongs_to :manufacturer
  has_many :models, :order => 'name ASC', :dependent => :destroy
  has_many :products, :through => :models, :order => 'name ASC', :uniq => true
  has_many_features
  has_attached_file :image, Configuration.default_image_options
  has_enumeration :production_status
  has_many_articles
  has_localized :name, :description
  
  validates_presence_of :name, :manufacturer
  validates_attachment_size :image, Configuration.default_image_size_options
  
  searches_on :name, :description
  
  def full_name
    self.name
  end
  
  def available_models
    self.models.select { |model| model.available? }
  end
  
  def available_products
    self.products.select { |product| product.available? }
  end
  
  def available?
    available_products.any?
  end
  
  def self.not_empty
    self.all(:include => :products).select { |make| make.available? }
  end
end
