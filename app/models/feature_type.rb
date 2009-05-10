class FeatureType < ActiveRecord::Base
  belongs_to :parent_feature_type, :class_name => 'FeatureType'
  has_many :child_feature_types, :class_name => 'FeatureType', :foreign_key => :parent_feature_type_id, :order => 'name ASC', :dependent => :destroy
  has_many :features, :order => 'name ASC', :dependent => :destroy
  has_attached_file :image, Configuration.default_image_options
  has_localized :name, :description
  
  validates_presence_of :name
  validates_attachment_size :image, Configuration.default_image_size_options
  
  searches_on :name, :description
  
  def self.find_all_for_featurable_type(featurable_type)
    self.all(:conditions => [ "featurable_type IS NULL OR featurable_type = ?", featurable_type ], :order => "name ASC", :include => :features)
  end
  
  def self.count_for_featurable_type(featurable_type)
    self.count(:conditions => [ "featurable_type IS NULL OR featurable_type = ?", featurable_type ])
  end
  
  def self.find_all_for_featurable(featurable)
    self.find_all_for_featurable_type(featurable.class.to_s)
  end
  
  def self.count_for_featurable(featurable)
    self.count_for_featurable_type(featurable.class.to_s)
  end
end
