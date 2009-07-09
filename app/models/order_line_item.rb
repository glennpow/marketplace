class OrderLineItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :price
  # FIXME...
  #has_one :product, :through => :price
  #has_one :vendor, :through => :price
  
  validates_presence_of :order, :price
  
  def product
    price.product
  end
  
  def vendor
    price.vendor
  end
  
  def unit_price
    price.amount
  end
  
  def total_price
    price.amount * quantity
  end
  
  def unit_weight
    product.weight
  end
  
  def total_weight
    product.weight * quantity
  end
end