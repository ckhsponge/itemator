# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  before_filter :authenticate_user
  before_filter :block_cdn
  before_filter :set_time_zone

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  protected
  def authenticate_user
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == ENV['APP_USER'] && password == ENV['APP_PASSWORD']
    end
  end
  
  def block_cdn
    render :text => "do not hit this url through a cdn" if request.host =~ /^cdn/i 
  end

  def set_time_zone
    Time.zone = ActiveSupport::TimeZone["Pacific Time (US & Canada)"]
  end
  
  def google_doclist_api
    unless @google_doclist_api
      @google_doclist_api = ::GData::Client::DocList.new
      @google_doclist_api.clientlogin(ENV['GOOGLE_EMAIL'], ENV['GOOGLE_PASSWORD'], nil, nil, nil, "HOSTED")
    end
    return @google_doclist_api
  end
  
  def google_spreadsheets_api
    unless @google_spreadsheets_api
      @google_spreadsheets_api = ::GData::Client::Spreadsheets.new
      @google_spreadsheets_api.clientlogin(ENV['GOOGLE_EMAIL'], ENV['GOOGLE_PASSWORD'], nil, nil, nil, "HOSTED")
    end
    return @google_spreadsheets_api
  end
end
