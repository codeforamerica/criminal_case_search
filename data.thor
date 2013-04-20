require './config/environment'

class Data < Thor
  include Mongo
  DIRECTORY = "NYPD"

  desc "load_from_xml PATH", "Load XML Datashare data from PATH"
  def load_from_xml(path)
    filenames = Dir.glob(File.join(path, DIRECTORY, "*.xml"))

    # Fix keys with periods; they are not valid as BSON keys.
    xml_parser = Nori.new(parser: :nokogiri, advanced_typecasting: false, :convert_tags_to => lambda { |tag| tag.gsub("\.","_") })

    filenames.each do |filename|
      doc_xml = ""
      File.open(filename, "r:UTF-8") do |file|
        doc_xml = file.read.force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
      end

      arrest_report = xml_parser.parse(doc_xml)

      Incident.create!(arrest_report: arrest_report)
    end
  end
end
