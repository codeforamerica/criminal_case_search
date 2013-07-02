# -*- coding: utf-8 -*-

require 'benchmark'
require './config/environment'

class Data < Thor
  BASE_PATH = "/Volumes/Datashare/"

  # Fix keys with periods; they are not valid BSON keys.
  @@xml_parser ||= Nori.new(parser: :nokogiri, advanced_typecasting: false, :convert_tags_to => lambda { |tag| tag.gsub("\.","_") })

  desc "load_arrest_reports", "Load XML Datashare Arrest Report data."
  def load_arrest_reports
    load_data ArrestReport, "NYPD"
  end

  desc "load_rap_sheets", "Load XML Datashare Rap Sheet data."
  def load_rap_sheets
    load_data RapSheet, "DCJS-2"
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

  desc "load_ror_reports", "Load XML Datashare ROR Report data."
  def load_ror_reports
    load_data RorReport, "CJA"
  end

  desc "load_court_proceeding_reports PATH", "Load OCA XML reports from some location"
  def load_court_proceeding_reports
    load_data CourtProceedingReport, "OCA - XML"
  end

  desc "load_oca_xml", "Load OCA XML reports."
  def load_oca_xml
    load_data OcaPush, "OCA\ -\ XML"
  end

  desc "load_arrest_tracking", "Load NYPD Arrestee Tracking XML dumps from some location"
  def load_arrest_tracking
    load_data ArresteeTracking, "ArrestTracking-Messages"
  end

  desc "load_docketing_notices PATH", "Load OCA Docketing Notice XML dumps from some location"
  def load_docketing_notices(path)
    docketing_notices = Dir.glob(File.join(path, "*"))
    docketing_notices.each do |filename|
      doc_xml = ""
      File.open(filename, "r:UTF-8") do |file|
        doc_xml = file.read.force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
      end

      docketing_notice_data = @@xml_parser.parse(doc_xml)
      docketing_notice = DocketingNotice.new(docketing_notice_data)
      incident = Incident.find_or_initialize_by(arrest_id: docketing_notice.arrest_id)
      docketing_notice.incident = incident
      docketing_notice.save!
      puts "new!" unless incident.persisted?
      puts "saved"
    end
  end

  desc "clear", "Removes all of the collections in the current database."
  def clear
    Mongoid.default_session.collections.map do |c|
      # Get all of the collections and tease out the DB object.
      Object.const_get(c.name.singularize.capitalize)
    end.each do |x|
      # Destroy all of the records in each collection and whine about it.
      puts "Deleted #{x.destroy_all} record(s) from the #{x} collection."
    end
  end

  desc "load [path]", "Loads as much data as we can muster. Takes an optional path override."
  def load(base_path = BASE_PATH)
    # Make sure there's some stuff to load.
    unless File.exists?(base_path)
      puts "We didn't see anything at #{base_path} to load! Exiting."
      return
    end

    self.load_arrest_reports
    self.load_rap_sheets
    self.load_complaints(base_path + "DANY")
    self.load_complaints(base_path + "KCDA")
    self.load_ror_reports
    self.load_arrest_tracking
    self.load_court_proceeding_reports
    self.load_docketing_notices(base_path + "Docketing")

    puts "Done loading data from #{base_path}."
  end

  private

  def load_data(model, dir)
    new_incidents = 0
    updated_incidents = 0
    path = BASE_PATH + dir

    time = Benchmark.realtime do
      files = Dir.glob(File.join(path, "*"))
      files.each do |filename|
        doc_xml = ""
        File.open(filename, "r:UTF-8") do |file|
          doc_xml = file.read.force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
        end

        parsed_data = @@xml_parser.parse(doc_xml)
        fresh_model = model.new(parsed_data)

        begin
          incident = Incident.find_or_initialize_by(arrest_id: fresh_model.arrest_id)
        rescue Exception => e
          puts fresh_model.inspect
          puts e.inspect
          next
        end

        fresh_model.incident = incident
        fresh_model.save!

        if incident.persisted?
          updated_incidents += 1
          print "◉ "
        else
          new_incidents += 1
          print "◎ "
        end
      end
    end

    puts ""
    puts "Imported #{updated_incidents + new_incidents} #{model} records from #{path} in #{time} seconds."
  end
end
