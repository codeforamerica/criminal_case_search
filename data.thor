require 'rubygems'
require 'bundler'
Bundler.require(:default)

class Data < Thor
  include Mongo
  DIRECTORY = "NYPD"

  desc "load_from_xml PATH", "Load XML Datashare data from PATH"
  def load_from_xml(path)
    client = MongoClient.new("localhost", 27017)
    db = client.db('datashare')
    collection = db.collection("arrestReports")

    filenames = Dir.glob(File.join(path, DIRECTORY, "*.xml"))

    filenames.each do |filename|
      doc_xml = ""
      File.open(filename, "r:UTF-8") do |file|
        doc_xml = file.read.force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
      end

      # Fix keys with periods; they are not valid as BSON keys.
      parser = Nori.new(parser: :nokogiri, advanced_typecasting: false, :convert_tags_to => lambda { |tag| tag.gsub("\.","_") })
      doc = parser.parse(doc_xml)

      doc_to_store = { xml: doc_xml, doc: doc}
      collection.insert(doc)
    end
  end
end
