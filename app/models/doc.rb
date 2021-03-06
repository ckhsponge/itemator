require 'gdata'
class Doc < ActiveRecord::Base
  SUCCESS_STATUS = "Good"
  FAIL_STATUS = "Failed"
  
  default_scope(:order => "folder, title")
  
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
  
  def self.distinct_folders
    docs = Doc.unscoped.find(:all, :select => "docs.folder", :group => "docs.folder", :order => "folder")
    return docs.collect{|i| i.folder}
  end
  
  def parse(google_client)
    begin
      items_csv = google_client.get(self.items_url).body
      order_csv = google_client.get(self.order_url).body
    
      parser = ItemParser.new(:path => self.path, :items_csv => items_csv, :order_csv => order_csv)
      parser.write_xml
      self.parsed = true
      self.success_at = Time.now
      self.status = SUCCESS_STATUS
      self.save!
    rescue GData::Client::RequestError => rerr
      self.parsed = false
      self.status = "#{FAIL_STATUS} - Google - #{rerr.to_s}" 
      self.save!
    rescue ItemException => iexc
      self.parsed = false
      self.status = "#{FAIL_STATUS} - Parse - #{iexc.to_s}" 
      self.save!
    rescue Exception => exc
      self.parsed = false
      self.status = "#{FAIL_STATUS} - Parse - #{exc.to_s}" 
      self.save!
      raise exc
    end
    
    return parser
  end
  
  def items_url
    "http://spreadsheets.google.com/feeds/download/spreadsheets/Export?key=#{self.key}&exportFormat=csv"
  end
  
  def order_url
    "#{items_url}&gid=1"
  end
  
  def example_url
    "http://#{ENV['HOST_CDN']}/#{Item::BASE_DIR}/#{self.path}/#{Item::PLACEMENT_DIR}/[placement id]/#{Item::FILE_NAME}"
  end
  
  def self.default_full_path(folder, title)
    "#{RAILS_ROOT}/public/#{Item::BASE_DIR}/#{folder}/#{title}/#{Item::FILE_NAME}"
  end
end
