class Price < ActiveRecord::Base
  belongs_to :vendor
  belongs_to :product
  
  validates_presence_of :vendor, :product
  
  def group
    self.vendor.group
  end
  
  def rank
    # TODO - Make this return the proper # of money icons to display
    3
  end
end
