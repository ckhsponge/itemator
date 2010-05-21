class ItemsController < ApplicationController
  
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
end
