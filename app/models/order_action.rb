class OrderAction < ActiveEnumeration::Base
  has_enumerated :purchase, :translate_key => 'marketplace.order_actions.purchase'
  has_enumerated :authorize, :translate_key => 'marketplace.order_actions.authorize'
  has_enumerated :capture, :translate_key => 'marketplace.order_actions.capture'
  has_enumerated :void, :translate_key => 'marketplace.order_actions.void'
  has_enumerated :credit, :translate_key => 'marketplace.order_actions.credit'
  has_enumerated :ship, :translate_key => 'marketplace.order_actions.ship'
  has_enumerated :deliver, :translate_key => 'marketplace.order_actions.deliver'
end
