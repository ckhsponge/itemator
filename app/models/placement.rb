require 'pp'
require 'builder'
require 'aws/s3'

class Placement
  DEFAULT_ID = ""
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
      key = row[i]
      next if key.blank? || key.strip.blank?
      key = key.strip
      item = item_hash[key]
      raise ItemException.new("no item found for '#{key}'") unless item
      @items << item
    end
    @dir = File.join(Item::BASE_DIR, dir)
    @dir = File.join(@dir, Item::PLACEMENT_DIR, @id) unless @id.blank?
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
  
  def self.public_dir
    File.join(RAILS_ROOT,"public")
  end
  
  def server_dir
    File.join(Placement.public_dir,@dir)
  end
  
  def server_path
    File.join(server_dir, Item::FILE_NAME)
  end
  
  def path
    File.join(@dir, Item::FILE_NAME)
  end
  
  def write
    raise ItemException.new( "no bucket declared") unless ENV['AWS_BUCKET']
    #bucket = Bucket.find( ENV['AWS_BUCKET'] )
    #raise ItematorException.new( "bucket not found: '#{ENV['AWS_BUCKET']}'") unless bucket
    begin
      AWS::S3::S3Object.store(self.path, self.to_xml, ENV['AWS_BUCKET']) #, {"Cache-Control" => "public,max-age=#{15.minutes}", "Vary" => "Accept-Encoding"} )
      puts "S3 Wrote: #{ENV['AWS_BUCKET']}/#{self.path}"
    rescue Exception => exc
      raise ItemException.new( "error in s3 write: #{exc.to_s}") 
    end
  end
  
  def write_file
    FileUtils.makedirs(server_dir)
    file = File.open(server_path, "w")
    file.write(self.to_xml)
    file.close
    puts "Wrote: #{file.path}"
  end
  
  def has_items?
    return @items && !@items.empty?
  end
end
