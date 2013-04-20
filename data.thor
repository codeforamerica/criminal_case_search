require './config/environment'

class Data < Thor
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

      arrest_report_data = xml_parser.parse(doc_xml)

      arrest_report = ArrestReport.new(arrest_report_data)

      # TODO: It appears that we have messages with duplicate documents in the sample dataset.
      # Need to establish which data should "win" here. Because data is loaded in filename order,
      # we're potentially using an inaccurate heuristic.
      incident = Incident.find_or_initialize_by(arrest_id: arrest_report.arrest_id)
      arrest_report.incident = incident
      arrest_report.save!
    end
  end
end
