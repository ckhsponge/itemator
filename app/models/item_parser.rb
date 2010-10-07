class ItemParser
  require 'csv'
  require 'pp'
  
  attr_accessor :path, :items_csv, :order_csv, :placement_hash
  
  def initialize(args)
    raise ItemException.new("no args") unless args
    @path = args[:path]
    @items_csv = args[:items_csv]
    @order_csv = args[:order_csv]
    
    raise ItemException.new("Missing path") if @path.empty?
    
    #puts @items_csv
    
    header = nil
    @item_hash = {}
    #CSV.open @items_csv.path, 'r' do |row|
    CSV.parse @items_csv do |row|
      #puts "ITEM: #{row.inspect}"
      unless header
        header = row
      else
        item = Item.new(header, row)
        raise ItemException.new("item id multi defined: '#{item.id}'") if @item_hash[item.id]
        @item_hash[item.id] = item
      end
    end
    puts "** Item Hash #{@item_hash.inspect}"
    
    header = nil
    @placement_hash = {}
    #CSV.open @order_csv.path, 'r' do |row|
    CSV.parse @order_csv do |row|
      next unless row && !row.first.nil? && row.size > 1
      #puts "ORDER: #{row.inspect}"
      unless header
        header = row
      else
        placement = Placement.new(@path, header, row, @item_hash)
        raise ItemException.new("placement multi defined: '#{placement.id}'") if @placement_hash[placement.id]
        @placement_hash[placement.id] = placement
      end
    end
    #check for empty placements
    raise ItemException.new("No items for any placements!") unless @placement_hash.values.inject(false) {|s,placement| s || placement.has_items?}
    raise ItemException.new("No default placement.") unless @placement_hash[Placement::DEFAULT_ID]
    raise ItemException.new("No items for default placement.") unless @placement_hash[Placement::DEFAULT_ID].has_items?
    puts "** placement_hash #{@placement_hash.inspect}"
  end
  
  def valid?
    return true
  end
  
  def write_xml
    @placement_hash.values.each do |placement|
      placement.write
    end
  end
end
