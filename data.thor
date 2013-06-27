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

  desc "load_complaints PATH", "Load XML Datashare complaint data from PATH"
  def load_complaints(path)
    dcjs_filenames = Dir.glob(File.join(path, "*.xml"))
    dcjs_filenames.each do |filename|
      doc_xml = ""
      File.open(filename, "r:UTF-8") do |file|
        doc_xml = file.read.force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
      end

      complaint_data = @@xml_parser.parse(doc_xml)
      arrest_ids = Complaint.new(complaint_data).arrest_ids

      arrest_ids.each do |arrest_id|
        # TODO: See above; if we have messages with duplicate documents, we need a better heuristic.
        incident = Incident.find_or_initialize_by(arrest_id: arrest_id)
        complaint = Complaint.new(complaint_data)
        complaint.incident = incident
        complaint.save!
      end
    end
  end

  desc "load_ror_reports PATH", "Load XML Datashare ROR Report data from PATH"
  def load_ror_reports(path)
    dcjs_filenames = Dir.glob(File.join(path, "*.xml"))
    dcjs_filenames.each do |filename|
      doc_xml = ""
      File.open(filename, "r:UTF-8") do |file|
        doc_xml = file.read.force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
      end

      ror_data = @@xml_parser.parse(doc_xml)
      ror_report = RorReport.new(ror_data)

      incident = Incident.find_or_initialize_by(arrest_id: ror_report.arrest_id)
      ror_report.incident = incident
      ror_report.save!
      puts "new!" unless incident.persisted?
      puts "saved"
    end
  end

  desc "load_court_proceeding_reports PATH", "Load OCA XML reports from some location"
  def load_court_proceeding_reports(path)
    oca_xml = Dir.glob(File.join(path, "*"))
    oca_xml.each do |filename|
      doc_xml = ""
      File.open(filename, "r:UTF-8") do |file|
        doc_xml = file.read.force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
      end

      oca_data = @@xml_parser.parse(doc_xml)
      court_proceeding_report = CourtProceedingReport.new(oca_data)

      incident = Incident.find_or_initialize_by(arrest_id: court_proceeding_report.arrest_id)
      court_proceeding_report.incident = incident
      court_proceeding_report.save!
      puts "new!" unless incident.persisted?
      puts "saved"
    end
  end

  desc "load_arrest_tracking PATH", "Load NYPD Arrestee Tracking XML dumps from some location"
  def load_arrest_tracking(path)
    arrest_tracking = Dir.glob(File.join(path, "*"))
    arrest_tracking.each do |filename|
      doc_xml = ""
      File.open(filename, "r:UTF-8") do |file|
        doc_xml = file.read.force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
      end

      arrest_data = @@xml_parser.parse(doc_xml)
      arrestee_tracking = ArresteeTracking.new(arrest_data)

      incident = Incident.find_or_initialize_by(arrest_id: arrestee_tracking.arrest_id)
      arrestee_tracking.incident = incident
      arrestee_tracking.save!
      puts "new!" unless incident.persisted?
      puts "saved"
    end
  end

  desc "clear_db", "Removes all of the collections in the current database."
  def clear_db
    Mongoid.default_session.collections.map { |c| Object.const_get(c.name.singularize.capitalize) }.each { |x| puts "Deleted #{x.destroy_all} record(s) from the #{x} collection." }
  end

  desc "load [path]", "Loads as much data as we can muster. Takes an optional path override."
  def load
    puts "Loading all data..."
    base_path = "/Volumes/Datashare/"
    self.load_arrest_reports(base_path + "NYPD")
    self.load_rap_sheets(base_path + "DCJS")
    self.load_complaints(base_path + "DANY")
    self.load_complaints(base_path + "KCDA")
    self.load_ror_reports(base_path + "CJA")
    self.load_arrest_tracking(base_path + "ArrestTracking-Messages")
  end
end
