require 'net/https'
require 'gdata'
require 'pp'
class ItemsController < ApplicationController
  
  def show
    @folder = params[:id]
    @docs = Doc.find(:all, :conditions => ["folder = ?", @folder])
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
        render :action => "success"
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
    @item_parser = @doc.parse(google_spreadsheets_api)
    render(:update) {|page| page.replace_html "#status#{params[:id]}", :file => "items/status_detail"}
    return
  end
  
end
