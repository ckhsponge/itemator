class Item
  attr_accessor :id, :values
  def initialize(header, row)
    raise ItemException.new("Missing items data") unless header && row
    @id = nil
    @values = ActiveSupport::OrderedHash.new
    id_index = nil
    header.each_with_index {|h, i| id_index = i if h && h.downcase == 'id' }
    raise ItemException.new("no id column for items") unless id_index
    puts "Index #{id_index}"
    header.each_with_index do |h, i|
      next unless h || i >= row.size
      if i == id_index
        @id = row[i]
      else
        value = row[i] ? row[i].to_s : nil
        @values[h.to_s] = value
      end
    end
    raise ItemException.new("no id value for item") unless @id
  end
end