class Cost < ActiveRecord::Base
  belongs_to :product
  belongs_to :country
  
  validates_presence_of :product, :country

  def group
    self.product.group
  end
end
