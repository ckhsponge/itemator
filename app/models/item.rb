class Item
  attr_accessor :id, :values
  def initialize(header, row)
    raise "invalid lengths" unless header && row && header.size == row.size
    @id = nil
    @values = ActiveSupport::OrderedHash.new
    id_index = nil
    header.each_with_index {|h, i| id_index = i if h && h.downcase == 'id' }
    raise "no id column" unless id_index
    puts "Index #{id_index}"
    header.each_with_index do |h, i|
      next unless h
      if i == id_index
        @id = row[i]
      else
        value = row[i] ? row[i].to_s : nil
        @values[h.to_s] = value
      end
    end
    raise "no id value" unless @id
  end
end