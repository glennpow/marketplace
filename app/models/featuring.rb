class Featuring < ActiveRecord::Base
  belongs_to :featurable, :polymorphic => true
  belongs_to :feature
end