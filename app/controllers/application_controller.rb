# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  protected
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
