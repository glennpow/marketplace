class Make < ActiveRecord::Base
  acts_as_resource :group => Proc.new { |make| make.manufacturer.group }
  acts_as_commentable
  acts_as_reviewable

  belongs_to :manufacturer
  has_many :models, :order => "#{Model.table_name}.name ASC", :dependent => :destroy
  has_many :products, :through => :models, :order => "#{Product.table_name}.name ASC", :uniq => true
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
  
  def available_models(vendor = nil)
    conditions = { "#{Product.table_name}.production_status" => ProductionStatus[:available] }
    conditions["#{Price.table_name}.vendor_id"] = vendor if vendor
    self.models.all(:include => { :products => :prices }, :conditions => conditions)
  end
  
  def available_products(vendor = nil)
    conditions = { "#{Product.table_name}.production_status" => ProductionStatus[:available] }
    conditions["#{Price.table_name}.vendor_id"] = vendor if vendor
    self.products.all(:include => { :products => :prices }, :conditions => conditions)
  end
  
  def available?
    available_products.any?
  end
  
  def self.available_for_vendor(vendor)
    self.all(:include => { :products => :prices }, :conditions => { "#{Price.table_name}.vendor_id" => vendor, "#{Product.table_name}.production_status" => ProductionStatus[:available] })
  end
end
