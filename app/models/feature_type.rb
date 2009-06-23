class FeatureType < ActiveEnumeration::Base
  has_enumerated :group, :translate_key => 'marketplace.feature_types.group'
  has_enumerated :single_select, :translate_key => 'marketplace.feature_types.single_select'
  has_enumerated :multiple_select, :translate_key => 'marketplace.feature_types.multiple_select'
  has_enumerated :option, :translate_key => 'marketplace.feature_types.option'
  has_enumerated :comparable, :translate_key => 'marketplace.feature_types.comparable'
  has_enumerated :boolean, :translate_key => 'marketplace.feature_types.boolean'
end
