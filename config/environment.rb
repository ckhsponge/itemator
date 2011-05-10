# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Itemator::Application.initialize!

private_settings = YAML.load(File.read("#{RAILS_ROOT}/config/private.yml"))
ENV['GOOGLE_EMAIL'] = private_settings['google_email']
ENV['GOOGLE_PASSWORD'] = private_settings['google_password']
ENV['APP_USER'] = private_settings['app_user']
ENV['APP_PASSWORD'] = private_settings['app_password']
Itemator::Application.config.secret_token = private_settings['secret_token']