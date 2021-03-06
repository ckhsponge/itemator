require 'pp'
require 'aws/s3'

class FoldersController < ApplicationController
  layout "items"
  skip_before_filter :authenticate_user, :only => :show
  skip_before_filter :block_cdn, :only => :show
  
  def index
    @folders = Doc.distinct_folders
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
    
    redirect_to :action => 'index'
  end
  
  #if the placement file does not exist then send the default
#  def default
#    path = Doc.default_full_path(params[:folder], params[:title])
#    if File.exist?(path)
#      headers["Cache-Control"]="max-age=#{15*60}"
#      headers["Vary"]="Accept-Encoding"
#      logger.warn "Rendering xml file: #{path}"
#      text = File.read(path)
#      render :xml => text
#    else
#      render :text => "default file not found", :status => 404
#    end
#  end
  
  def show
    path = request.path
    path = path.sub(/^\//, '') #remove leading slash
    begin
      puts "Looking for: #{path}"
      begin
        object = AWS::S3::S3Object.find(path, ENV['AWS_BUCKET'])
      rescue  AWS::S3::NoSuchKey => nsk0
        path = path.sub(/\/placements\/.*$/,"/items.xml")
        puts "NOT FOUND, trying: #{path}"
        object = AWS::S3::S3Object.find( path, ENV['AWS_BUCKET'])
      end
      value = object.value
      headers["Cache-Control"]="public, max-age=#{15.minutes}"
      headers["Vary"]="Accept-Encoding"
      render :text => value
    rescue  AWS::S3::NoSuchKey => nsk
      raise ItemException.new("no such key: #{path}")
    end
  end
end
