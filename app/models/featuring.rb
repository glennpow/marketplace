class Featuring < ActiveRecord::Base
  belongs_to :featurable, :polymorphic => true
  belongs_to :feature
  
  validates_presence_of :featurable, :feature
  
  def value_name
    case feature.feature_type
    when FeatureType[:comparable]
      "#{value} #{feature.units}"
    when FeatureType[:boolean]
      value.true? ? I18n.t(:yes) : I18n.t(:no)
    end
  end
end