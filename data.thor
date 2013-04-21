require './config/environment'

class Data < Thor
  # Fix keys with periods; they are not valid BSON keys.
  @@xml_parser ||= Nori.new(parser: :nokogiri, advanced_typecasting: false, :convert_tags_to => lambda { |tag| tag.gsub("\.","_") })

  desc "load_arrest_reports PATH", "Load XML Datashare Arrest Report data from PATH"
  def load_arrest_reports(path)
    nypd_filenames = Dir.glob(File.join(path, "*.xml"))
    nypd_filenames.each do |filename|
      doc_xml = ""
      File.open(filename, "r:UTF-8") do |file|
        doc_xml = file.read.force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
      end

      arrest_report_data = @@xml_parser.parse(doc_xml)
      arrest_report = ArrestReport.new(arrest_report_data)

      # TODO: It appears that we have messages with duplicate documents in the sample dataset.
      # Need to establish which data should "win" here. Because data is loaded in filename order,
      # we're potentially using an inaccurate heuristic.
      incident = Incident.find_or_initialize_by(arrest_id: arrest_report.arrest_id)
      arrest_report.incident = incident
      arrest_report.save!
    end
  end


  desc "load_rap_sheets PATH", "Load XML Datashare Rap Sheet data from PATH"
  def load_rap_sheets(path)
    dcjs_filenames = Dir.glob(File.join(path, "*.xml"))
    dcjs_filenames.each do |filename|
      doc_xml = ""
      File.open(filename, "r:UTF-8") do |file|
        doc_xml = file.read.force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
      end

      rap_sheet_data = @@xml_parser.parse(doc_xml)
      rap_sheet = RapSheet.new(rap_sheet_data)

      begin
        # TODO: See above; if we have messages with duplicate documents, we need a better heuristic.
        incident = Incident.find_or_initialize_by(arrest_id: rap_sheet.arrest_id)
      rescue Exception => e
        # TODO: The sample dataset includes many truncated files with invalid XML. Ignoring for now.
        puts "Cannot parse Arrest ID in #{filename}, skipping..."
        next
      end
      rap_sheet.incident = incident
      rap_sheet.save!
    end

  end
end
