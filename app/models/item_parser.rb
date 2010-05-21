class ItemParser
  require 'csv'
  require 'pp'
  
  attr_accessor :path, :items_csv, :order_csv, :placement_hash
  
  def initialize(args)
    raise "no args" unless args
    @path = args[:path]
    @items_csv = args[:items_csv]
    @order_csv = args[:order_csv]
    
    header = nil
    @item_hash = {}
    CSV.open @items_csv.path, 'r' do |row|
      puts "r: #{row.inspect}"
      unless header
        header = row
      else
        item = Item.new(header, row)
        raise "item id already defined" if @item_hash[item.id]
        @item_hash[item.id] = item
      end
    end
    puts @item_hash.inspect
    
    header = nil
    @placement_hash = {}
    CSV.open @order_csv.path, 'r' do |row|
      unless header
        header = row
      else
        placement = Placement.new(@path, header, row, @item_hash)
        raise "placement already defined: #{placement.id}" if @placement_hash[placement.id]
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
