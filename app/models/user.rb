class User < ActiveRecord::Base
  include Clearance::User
  has_many :groups, :through => :acls
  has_many :games
  has_one :gamertag_cache
end
