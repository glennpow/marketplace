class Cost < ActiveRecord::Base
  belongs_to :product
  belongs_to :region
  
  validates_presence_of :product, :region

  def group
    self.product.group
  end
end
