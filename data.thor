require 'benchmark'
require './config/environment'

class Data < Thor
  BASE_PATH = "/Volumes/Datashare/"

  # Fix keys with periods; they are not valid BSON keys.
  @@xml_parser ||= Nori.new(parser: :nokogiri, advanced_typecasting: false, :convert_tags_to => lambda { |tag| tag.gsub("\.","_") })

  desc "load_arrest_reports", "Load XML Datashare Arrest Report data."
  def load_arrest_reports(incidents = nil)
    load_data ArrestReport, "NYPD", incidents
  end

  desc "load_rap_sheets", "Load XML Datashare Rap Sheet data."
  def load_rap_sheets(incidents = nil)
    load_data RapSheet, "DCJS-2", incidents
  end

  desc "load_complaints PATH", "Load XML Datashare complaint data from PATH"
  def load_complaints(path, incidents = nil)
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

        if incidents.blank?
          incident = Incident.find_or_initialize_by(arrest_id: arrest_id)
        else
          puts "NEW!"
          incident = Incident.where(:complaint.exists => false).first
          if incident.blank?
            puts "no incident found missing a complaint"
            next
          end
        end

        complaint = Complaint.new(complaint_data)
        complaint.incident = incident
        complaint.save!
      end
    end
  end

  desc "load_ror_reports", "Load XML Datashare ROR Report data."
  def load_ror_reports(incidents = nil)
    load_data RorReport, "CJA", incidents
  end

  desc "load_court_proceeding_reports PATH", "Load OCA XML reports from some location"
  def load_court_proceeding_reports(incidents = nil)
    load_data CourtProceedingReport, "OCA - XML", incidents
  end

  desc "load_arrest_tracking", "Load NYPD Arrestee Tracking XML dumps from some location"
  def load_arrest_tracking(incidents = nil)
    load_data ArresteeTracking, "ArrestTracking-Messages", incidents
  end

  desc "load_docketing_notices", "Load OCA Docketing Notice XML dumps."
  def load_docketing_notices(incidents = nil)
    load_data DocketingNotice, "Docketing", incidents
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
    self.load_docketing_notices

    puts "Done loading data from #{base_path}."
  end

  desc "reset", "Runs the `clear` and then `load` tasks. For, you know, resetting."
  def reset
    self.clear
    self.load
  end

  desc "load_and_compose", "Load all data and compose incomplete documents into complete sets."
  def load_and_compose_data(n = 100)
    self.load_arrest_reports

    incidents = Incident.where(:arrest_report.exists => true)

    self.load_rap_sheets(incidents)
    self.load_complaints(BASE_PATH + "DANY", incidents)
    self.load_complaints(BASE_PATH + "KCDA", incidents)
    self.load_ror_reports(incidents)
    self.load_arrest_tracking(incidents)
    self.load_court_proceeding_reports(incidents)
    self.load_docketing_notices(incidents)

    Incident.where(:arrest_report.exists => false).destroy_all
    Incident.where(:complaint.exists => false).destroy_all
  end

  private

  def load_data(model, dir, incidents = nil)
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

        header_location = doc_xml.index('<e:Enterprise')
        if header_location && (header_location > 0)
          doc_xml = doc_xml[doc_xml.index('<e:Enterprise')..-1]
        end
          
        parsed_data = @@xml_parser.parse(doc_xml)
        fresh_model = model.new(parsed_data)

        begin
          if incidents.blank?
            incident = Incident.find_or_initialize_by(arrest_id: fresh_model.arrest_id)
          else
            puts "NEW!"
            model_sym = model.name.underscore.to_sym
            incident = Incident.where(model_sym.exists => false).first
            if incident.blank?
              puts "no incident found missing a " + model.name
              next
            end
          end
        rescue Exception => e
          puts filename
          puts fresh_model.inspect
          puts e.inspect
          puts header_location
          binding.pry
          next
        end

        fresh_model.incident = incident
        fresh_model.save!

        if incident.persisted?
          updated_incidents += 1
          print "+"
        else
          new_incidents += 1
          print "."
        end
      end
    end

    puts ""
    puts "Imported #{updated_incidents + new_incidents} #{model} records from #{path} in #{time} seconds."
  end
end
