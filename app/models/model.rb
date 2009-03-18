class Model < ActiveRecord::Base
  acts_as_resource :group => Proc.new { |model| model.make.group }
  acts_as_commentable
  acts_as_reviewable

  belongs_to :make
  has_one :manufacturer, :through => :make
  has_many :products, :order => 'name ASC', :dependent => :destroy
  has_many_features :include => :make
  has_attached_file :image, Configuration.default_image_options
  has_enumeration :production_status
  has_many_articles
  
  validates_presence_of :name, :description, :make
  validates_attachment_size :image, Configuration.default_image_size_options
  
  searches_on :name, :description
  
  def full_name
    [ self.make.name, self.name ].join(' ')
  end
  
  def production_status_with_make
    self.production_status_without_make || self.make.production_status
  end
  alias_method_chain :production_status, :make
  
  def available_products
    self.products.select { |product| product.available? }
  end
  
  def available?
    self.production_status == ProductionStatus[:available]
  end
end
