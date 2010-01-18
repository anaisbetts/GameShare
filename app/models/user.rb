class User < ActiveRecord::Base
  include Clearance::User
  has_many :groups, :through => :acls
  validates_associated :user
  has_many :games
end
