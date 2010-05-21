# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_items_session',
  :secret      => 'ec5acabeed9dbc17b4b23c390d3a62b4db1890292316778bb04fb7f7ff9cab8782a96c3b75d313b67a1b41b3465773deb124cfa81617246a32bc35b3fefd5cc0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
