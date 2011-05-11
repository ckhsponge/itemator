# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Itemator::Application.initialize!

private_file = "#{RAILS_ROOT}/config/private.yml"
if File.exists? private_file
  private_settings = YAML.load(File.read(private_file))
  private_settings.keys.each do |key|
    ENV[key.upcase] = private_settings[key]
  end
end


if ENV['NEWRELIC_LICENSE_KEY']
  NewRelic::Control.instance['license_key'] = ENV['NEWRELIC_LICENSE_KEY']
  NewRelic::Agent.agent.shutdown
  NewRelic::Control.instance.start_agent
end

Itemator::Application.config.secret_token = ENV['SECRET_TOKEN'] if ENV['SECRET_TOKEN']

require 'aws/s3'
AWS::S3::Base.establish_connection!(
  :access_key_id     => ENV['AWS_ACCESS_KEY_ID'], 
  :secret_access_key => ENV['SECRET_ACCESS_KEY']
)

