class ProductionStatus < ActiveEnumeration::Base
  has_enumerated :unreleased, :translate_key => 'marketplace.production_statuses.unreleased'
  has_enumerated :available, :translate_key => 'marketplace.production_statuses.available'
  has_enumerated :discontinued, :translate_key => 'marketplace.production_statuses.discontinued'
end
