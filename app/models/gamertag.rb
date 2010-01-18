class Gamertag < ActiveRecord::Base
  belongs_to :user

  class << self
    def from_user(user)
      # Fetch their Gamertag information from the web service
      response = Net::HTTP.get(URI.parse('http://xboxapi.duncanmackenzie.net/gamertag.ashx?Gamertag=#{user.gamertag}'))
    end
  end
end
