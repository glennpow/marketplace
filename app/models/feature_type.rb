class FeatureType < ActiveRecord::Base
  belongs_to :parent_feature_type, :class_name => 'FeatureType'
  has_many :child_feature_types, :class_name => 'FeatureType', :foreign_key => :parent_feature_type_id, :order => 'name ASC', :dependent => :destroy
  has_many :features, :order => 'name ASC', :dependent => :destroy
  has_attached_file :image, Configuration.default_image_options
  
  validates_presence_of :name, :description
  validates_attachment_size :image, Configuration.default_image_size_options
  
  searches_on :name, :description
end
