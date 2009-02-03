class OfferType < ActiveEnumeration::Base
  has_enumerated :discount_amount, :translate_key => 'marketplace.offer_types.discount_amount'
  has_enumerated :discount_percent, :translate_key => 'marketplace.offer_types.discount_percent'
  has_enumerated :refund_amount, :translate_key => 'marketplace.offer_types.refund_amount'
end
