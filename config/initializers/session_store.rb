# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_gameshare_session',
  :secret      => '4c275ae690052f65f825cb11bb79230a41d20704a2a8fa49a6e105d71941f321185aeb83e9b12a755a1d7aebc4ba1a37a61d6121150dc87a92652213476f5860'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
