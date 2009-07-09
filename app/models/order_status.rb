class OrderStatus < ActiveEnumeration::Base
  has_enumerated :pending, :translate_key => 'marketplace.order_statuses.pending', :position => 0
  has_enumerated :purchased, :translate_key => 'marketplace.order_statuses.purchased', :position => 1
  has_enumerated :shipped, :translate_key => 'marketplace.order_statuses.shipped', :position => 2
  has_enumerated :delivered, :translate_key => 'marketplace.order_statuses.delivered', :position => 3
  has_enumerated :failed, :translate_key => 'marketplace.order_statuses.failed', :position => 4
end
