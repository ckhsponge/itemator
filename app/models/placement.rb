require 'pp'
class Placement
  BASE_DIR = "cache"
  FILE_NAME = "items.xml"
  attr_accessor :id, :items
  def initialize(dir, header, row, item_hash)
    raise ItemException.new("missing header for placements") unless header
    raise ItemException.new("missing placement data") unless row
    raise ItemException.new("missing item_hash") unless item_hash
    item_indices = []
    placement_index = nil
    header.each_with_index {|h, i| item_indices << i if h && h.to_s.downcase.index("item ") == 0 }
    header.each_with_index {|h, i| placement_index = i if h && h.downcase == "placement id" }
    raise ItemException.new("no placement column") unless placement_index
    @id = row[placement_index] || ""
    @items = []
    item_indices.each do |i|
      next if row.size < i
      next if row[i].blank?
      raise ItemException.new("no item found for '#{row[i]}'") unless item_hash[row[i]]
      item = item_hash[row[i]]
      @items << item
    end
    @dir = File.join("cache", dir)
    @dir = File.join(@dir, "placements", @id) unless @id.blank?
  end
  
  def to_xml
    xm = Builder::XmlMarkup.new(:indent => 2)
    xm.instruct!
    xm.browse do
      xm.items do
        @items.each do |item|
          xm.item do
            item.values.each_pair do |key, value|
              key = key.gsub(" ","_") unless key.include?("=")
              params = hasherize(key)
              key = key.gsub(/\s.*/, '')
              xm.method_missing(key, value, params)
            end
          end
        end
      end
    end
    return xm.target!
  end
  
  def hasherize(s)
    result = {}
    return result unless s
    s.split(/\s/).each do |word|
      next unless word.include?("=")
      pair = word.split("=")
      next unless pair && pair.size == 2
      result[pair[0]] = pair[1].gsub(/'|"/, '')
    end
    return result
  end
  
  def server_dir
    File.join(RAILS_ROOT,"public",@dir)
  end
  
  def server_path
    File.join(server_dir, FILE_NAME)
  end
  
  def path
    File.join(@dir, FILE_NAME)
  end
  
  def write
    FileUtils.makedirs(server_dir)
    file = File.open(server_path, "w")
    file.write(self.to_xml)
    file.close
    puts "Wrote: #{file.path}"
  end
end
