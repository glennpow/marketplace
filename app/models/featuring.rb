class Featuring < ActiveRecord::Base
  belongs_to :featurable, :polymorphic => true
  belongs_to :feature
  
  validates_presence_of :featurable, :feature
  
  def value_name
    case feature.feature_type
    when FeatureType[:comparable]
      "#{value} #{feature.units}"
    when FeatureType[:boolean]
      value.zero? ? I18n.t(:no) : I18n.t(:yes)
    end
  end
end