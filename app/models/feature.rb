class Feature < ActiveRecord::Base
  belongs_to :feature_type
  has_and_belongs_to_many :products
  has_attached_file :image, Configuration.default_image_options
  has_many :featurings, :dependent => :destroy
  
  validates_presence_of :name, :description, :feature_type
  validates_attachment_size :image, Configuration.default_image_size_options
  
  searches_on :name, :description
    
  named_scope :by_type, :include => :feature_type, :order => "#{FeatureType.table_name}.name ASC, #{Feature.table_name}.name ASC"

  def name_with_type
    "#{self.feature_type.name} - #{self.name}"
  end
end