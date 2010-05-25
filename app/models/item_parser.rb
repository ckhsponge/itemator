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
      puts "r: #{row.inspect}"
      unless header
        header = row
      else
        item = Item.new(header, row)
        raise ItemException.new("item id multi defined: '#{item.id}'") if @item_hash[item.id]
        @item_hash[item.id] = item
      end
    end
    puts @item_hash.inspect
    
    header = nil
    @placement_hash = {}
    #CSV.open @order_csv.path, 'r' do |row|
    CSV.parse @order_csv do |row|
      unless header
        header = row
      else
        placement = Placement.new(@path, header, row, @item_hash)
        raise ItemException.new("placement multi defined: '#{placement.id}'") if @placement_hash[placement.id]
        @placement_hash[placement.id] = placement
      end
    end
    puts "placement_hash #{@placement_hash}"
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
