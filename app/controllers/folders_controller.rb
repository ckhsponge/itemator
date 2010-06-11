require 'pp'
class FoldersController < ApplicationController
  layout "items"
  skip_before_filter :authenticate_user, :only => :default
  
  def list
    @folders = Doc.find(:all, :group => "folder").collect{|i| i.folder}
  end
  
  def refresh_docs
    response = google_doclist_api.get("http://docs.google.com/feeds/documents/private/full?showfolders=true")
    feed = response.to_xml
    
    full_id = nil
    feed.elements.each('entry') do |entry|
#      entry.elements.each do |f|
#        puts "ENTRY #{f.to_s}"
#      end
      
      folder = nil
      entry.elements.each('category') do |link|
        folder = link.attribute('label').value if link.attribute('scheme').to_s.starts_with?("http://schemas.google.com/docs/2007/folders")
      end
      
      title = entry.elements['title'].text
      
      entry.elements.each('id') do |c|
        full_id = c.text
      end
      key = full_id[/full\/spreadsheet%3A(.*)/, 1]
      
      next if folder.blank? || key.blank?
      Doc.get_or_create(:folder => folder, :title => title, :key => key)
    end
    
    redirect_to :action => 'list'
  end
  
  #if the placement file does not exist then send the default
  def default
    path = Doc.default_full_path(params[:folder], params[:title])
    if File.exist?(path)
      headers["Cache-Control"]="max-age=#{15*60}"
      headers["Vary"]="Accept-Encoding"
      render :file => path
    else
      render :text => "default file not found", :status => 404
    end
  end
end
