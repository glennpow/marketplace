class QuoteRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :vendor
  belongs_to :product
  
  validates_presence_of :user, :vendor, :product
end
