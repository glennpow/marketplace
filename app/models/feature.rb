class Feature < ActiveRecord::Base
  acts_as_list :scope => :parent
  acts_as_tree :order => 'position ASC, name ASC'
  has_enumeration :feature_type
  has_attached_file :image, Configuration.default_image_options
  has_many :featurings, :dependent => :destroy
  has_localized :name, :description
  
  validates_presence_of :name
  validates_attachment_size :image, Configuration.default_image_size_options
  
  searches_on :name, :description, :feature_type
  
  def searchable_children(is_supplier = false)
    conditions = is_supplier ? { :compare_only => false } : { :compare_only => false, :supplier_only => false }
    children.find(:all, :conditions => conditions, :order => 'position ASC, name ASC')
  end
  
  def self.searchable_roots(is_supplier = false)
    conditions = is_supplier ? { :parent_id => nil, :compare_only => false } : { :parent_id => nil, :compare_only => false, :supplier_only => false }
    find(:all, :conditions => conditions, :order => 'position ASC, name ASC')
  end
  
  def self.highlighted
    find(:all, :conditions => { :highlight => true }, :order => 'highlight_position ASC, name ASC')
  end
  
  def self.find_all_for_featurable_type(featurable_type, parent = nil)
    features = self.all(:conditions => [ "(featurable_type IS NULL OR featurable_type = ?) AND parent_id #{parent.nil? ? 'IS' : '='} ?", featurable_type.to_s.underscore, parent ], :order => "position ASC, name ASC")
  end
  
  def self.count_for_featurable_type(featurable_type, parent = nil)
    self.count(:conditions => [ "(featurable_type IS NULL OR featurable_type = ?) AND parent_id #{parent.nil? ? 'IS' : '='} ?", featurable_type.to_s.underscore, parent ])
  end
  
  def self.find_all_for_featurable(featurable, parent = nil)
    self.find_all_for_featurable_type(featurable.class.to_s, parent)
  end
  
  def self.count_for_featurable(featurable, parent = nil)
    self.count_for_featurable_type(featurable.class.to_s, parent)
  end
end
