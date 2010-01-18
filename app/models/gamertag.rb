class Gamertag < ActiveRecord::Base
  belongs_to :user

  class << self
    def from_user(user, tag)
      # Fetch their Gamertag information from the web service
      response = Net::HTTP.get(URI.parse("http://xboxapi.duncanmackenzie.net/gamertag.ashx?Gamertag=#{tag}"))
      gamertag_info = Hash.from_xml(response)
      raise "Invalid Gamertag" unless valid_gamertag? gamertag_info

      Gamertag.new do |x| 
        x.name = tag
        x.user_id = user.id
        x.gamertag_yaml = gamertag_info.to_yaml
      end
    end

    def valid_gamertag?(info)
      begin
        return false if info["XboxInfo"]["PresenceInfo"]["Valid"] != "true"
      rescue # XML isn't formed correctly
        return false
      end

      true
    end
  end

  def raw_data
    @info || (@info = YAML.load(gamertag_yaml))
  end
end
