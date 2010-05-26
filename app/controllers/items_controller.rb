require 'net/https'
require 'gdata'
require 'pp'
class ItemsController < ApplicationController
  
  before_filter :google_sign_in, :only => [:update, :refresh_docs] 
  
  def list
    @docs = Doc.find(:all)
  end
  
  def new
    
  end
  
  def create
    begin
      @item_parser = ItemParser.new(params[:items])
      @item_parser.write_xml
      if @item_parser.valid?
        #puts @item_parser.placement_hash[''].to_xml
        #@item_parser.placement_hash[''].write
        render :action => "show"
      else
        render :action => "new"
      end
    rescue ItemException => exc
      flash[:note] = exc.to_s
      render :action => "new"
    end
  end
  
  def update
    @doc = Doc.find(params[:id])
    @item_parser = @doc.parse(@google_client)
    render :action => "status_detail", :layout => false
  end
  
  def refresh_docs
    response = @google_client.get('http://docs.google.com/feeds/documents/private/full?showfolders=true')
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

end
