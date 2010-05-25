require 'gdata'
class Doc < ActiveRecord::Base
  
  def self.get_or_create(args = {})
    puts "#{args[:folder]}, #{args[:title]}, #{args[:key]}"
    args = args.clone
    args[:path] = self.make_path(args[:folder], args[:title])
    doc = self.find_by_path(args[:path]) || self.create!(args)
    return doc
  end
  
  def self.make_path(folder, title)
    "#{folder.downcase.gsub(' ','_')}/#{title.downcase.gsub(' ','_')}"
  end
  
  def parse(google_client)
    items_csv = google_client.get(self.items_url).body
    order_csv = google_client.get(self.order_url).body
    
    parser = ItemParser.new(:path => self.path, :items_csv => items_csv, :order_csv => order_csv)
    parser.write_xml
    self.parsed = true
    self.save!
  end
  
  def items_url
    "http://spreadsheets.google.com/pub?key=#{self.key}&output=csv"
  end
  
  def order_url
    "#{items_url}&gid=1"
  end
end
