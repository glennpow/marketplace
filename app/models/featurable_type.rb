class FeaturableType < ActiveEnumeration::Base
  has_enumerated :product, :translate_key => 'marketplace.product'
  has_enumerated :model, :translate_key => 'marketplace.model'
end
