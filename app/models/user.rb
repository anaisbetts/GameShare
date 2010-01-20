class User < ActiveRecord::Base
  include Clearance::User

  has_many :groups, :through => :acls
  has_many :games
  has_one :gamertag
  after_save :set_gamertag

  attr_accessible :gamertag_name 
  attr_accessor :gamertag_name 

  validates_each :gamertag_name do |record, attr, value|
    gt = Gamertag.find_by_name(value)
    record.errors.add :gamertag_name, "Gamertag already taken"  if gt and gt.user_id != record.id 
    next if gt

    begin
      # FIXME: We fetch their Gamertag XML twice here
      Gamertag.from_user(record, value)
    rescue Exception => e
      record.errors.add :gamertag_name, e.message
    end
  end

  def set_gamertag
    new_tag = gamertag || Gamertag.find_by_name(gamertag_name) 
    unless new_tag
      new_tag = Gamertag.from_user(self, gamertag_name)
      new_tag.save!
    end

    gamertag = new_tag
    true
  end
end
