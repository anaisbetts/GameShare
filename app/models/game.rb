class Game < ActiveRecord::Base
  belongs_to :user
  has_one :amazonitem
end
