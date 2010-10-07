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
      next unless row && row.size > 1 #skip rows that are nil or that have 1 or less columns
      #puts "ORDER: #{row.inspect}"
      unless header
        header = row
      else
        placement = Placement.new(@path, header, row, @item_hash)
        raise ItemException.new("placement multi defined: '#{placement.id}'") if @placement_hash[placement.id]
        @placement_hash[placement.id] = placement
      end
    end
    puts "** placement ids #{@placement_hash.keys.sort.inspect}"
    puts "** placement_hash #{@placement_hash.inspect}"
    #check for empty placements
    raise ItemException.new("No items for any placements!") unless @placement_hash.values.inject(false) {|s,placement| s || placement.has_items?}
    raise ItemException.new("No default placement.") unless @placement_hash[Placement::DEFAULT_ID]
    raise ItemException.new("No items for default placement.") unless @placement_hash[Placement::DEFAULT_ID].has_items?
  end
  
  def valid?
    return true
  end
  
  def write_xml
    rmdir = File.join(Placement.public_dir, Item::BASE_DIR, @path)
    puts "Removing dir: #{rmdir}"
    FileUtils.remove_dir(rmdir, true) #force removal
    @placement_hash.values.each do |placement|
      placement.write
    end
  end
end
