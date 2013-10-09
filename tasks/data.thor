require 'benchmark'
require './config/environment'

class Data < Thor
  BASE_PATH = "/Volumes/Datashare/"

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

      complaints = Complaint.from_xml(doc_xml)
      complaints.each { |c| c.save! }
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

  desc "generate_samples [N]", "Generate N sample Incidents. Defaults to 100 samples."
  def generate_samples(n = 100)
    sample_charges = JSON.parse(File.read("fixtures/charges.json"))

    n.to_i.times do
      borough_code = DatashareFilter::BOROUGH_CODES.sample
      borough = DatashareFilter::BOROUGH_CODES_TO_NAMES[borough_code]

      arrest_id = borough_code + Random.rand(10000000...30000000).to_s
      while Incident.where(arrest_id: arrest_id).count > 0
        arrest_id = borough_code + Random.rand(10000000...30000000).to_s
      end

      incident = Incident.create!(arrest_id: arrest_id)

      borough_to_precinct = {
        "Manhattan" => %w(1 5 6 7 9 10 13 14 17 18 19 20 22 23 24 25 26 28 30 32 33 34),
        "Staten Island" => %w(120 121 122 123),
        "Brooklyn" => %w(60 61 62 63 66 67 68 69 70 71 72 73 75 76 77 78 79 81 83 84 88 90 94),
        "Bronx" => %w(40 41 42 43 44 45 46 47 48 49 50 52),
        "Queens" => %w(100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115)
      }
      dat = [true, false].sample
      arrest_report_attributes = {
        incident: incident,
        arrest_id: arrest_id,
        borough: borough,
        defendant_first_name: Faker::Name.first_name,
        defendant_last_name: Faker::Name.last_name,
        defendant_sex: ["M","F"].sample,
        defendant_age: Random.rand(18..65),
        precinct: borough_to_precinct[borough].sample,
        desk_appearance_ticket: dat,
        desk_appearance_ticket_court_date: dat ? Random.rand(0..10).days.from_now : nil
      }
      arrest_report = ArrestReport.create!(arrest_report_attributes)

      number_of_prior_convictions = Random.rand(0..10)
      prior_conviction_type_options = ["Drug", "Misdemeanor Assault", "Criminal Contempt", "Sex Offense", "Untracked"]
      prior_conviction_severity_options = ["Felony", "Violent Felony", "Misdemeanor", "Other"]
      if number_of_prior_convictions == 0
        prior_conviction_types = []
        prior_conviction_severities = []
      else
        prior_conviction_types = number_of_prior_convictions.times.map { prior_conviction_type_options.sample }
        prior_conviction_severities = number_of_prior_convictions.times.map { prior_conviction_severity_options.sample }.uniq
      end
      on_probation = number_of_prior_convictions > 0 ? [true, false].sample : false
      on_parole = !on_probation && number_of_prior_convictions > 0 ? [true, false].sample : false
      rap_sheet_attributes = {
        incident: incident,
        arrest_id: arrest_id,
        defendant_sex: incident.defendant_sex,
        defendant_age: incident.defendant_age,
        number_of_prior_criminal_convictions: number_of_prior_convictions,
        number_of_other_open_cases: number_of_prior_convictions > 0 ? Random.rand(0..4) : 0,
        has_failed_to_appear: number_of_prior_convictions > 0 ? [true, false].sample : false,
        prior_conviction_types: prior_conviction_types,
        prior_conviction_severities: prior_conviction_severities,
        has_outstanding_bench_warrant: number_of_prior_convictions > 0 ? [true, false].sample : false,
        persistent_misdemeanant: number_of_prior_convictions > 5 ? [true, false].sample : false,
        on_probation: on_probation,
        on_parole: on_parole
      }
      rap_sheet = RapSheet.create!(rap_sheet_attributes)

      complaint_attributes = {
        incident: incident,
        arrest_id: arrest_id,
        charges: sample_charges.sample
      }
      complaint = Complaint.new(complaint_attributes)
      complaint.set_attributes_based_on_charges
      complaint.save!

      ror_recommendations = [
        "Not recommended for ROR",
        "High risk for FTA",
        "Recommended for ROR",
        "Moderate risk for ROR",
        "No recommendation",
        "Interview incomplete",
        "Defendant declined interview"
      ]
      ror_report_attributes = {
        incident: incident,
        arrest_id: arrest_id,
        recommendations: [ror_recommendations.sample]
      }
      ror_report = RorReport.create!(ror_report_attributes)

      borough_to_docket_code = {
        "Manhattan" => "NY",
        "Staten Island" => "RI",
        "Brooklyn" => "KN",
        "Bronx" => "BX",
        "Queens" => "QN"
      }
      #TODO: separate out Redhook and MCC cases out, and DATs
      borough_to_courthouses = {
        "Manhattan" => ["New York County", "Midtown Community Court"],
        "Staten Island" => ["Richmond County"],
        "Brooklyn" => ["Kings County", "Redhook Community Court"],
        "Bronx" => ["Bronx County"],
        "Queens" => ["Queens County"]
      }
      courthouses_to_parts = {
        "New York County" => ["APAR3", "APAR1"],
        "Midtown Community Court" => ["APAR6"],
        "Richmond County" => ["APAR1", "APAR4"],
        "Kings County" => ["APAR2", "APAR2/3A", "APAR1/3"],
        "Redhook Community Court" => ["APAR6"],
        "Bronx County" => ["APAR2", "APAR1/3"],
        "Queens County" => ["AR2A", "APAR1/3", "APAR4/3"]
      }
      courthouse = borough_to_courthouses[borough].sample
      part = courthouses_to_parts[courthouse].sample
      docket_number = "#{Date.today.year}#{borough_to_docket_code[borough]}#{sprintf("%06d",Random.rand(050000..200000))}"
      while Incident.where(docket_number: docket_number).count > 0
        docket_number = "#{Date.today.year}#{borough_to_docket_code[borough]}#{sprintf("%06d",Random.rand(050000..200000))}"
      end
      docketing_notice_attributes = {
        incident: incident,
        arrest_id: arrest_id,
        docket_number: docket_number,
        next_court_date: Random.rand(0..8).days.from_now,
        next_courthouse: courthouse,
        next_court_part: part
      }
      docketing_notice = DocketingNotice.create!(docketing_notice_attributes)

      arraigned = Random.rand(0..10) <= 2 ? true : false
      if arraigned
        arraignment_outcome = ["ROR", "Bail Set"].sample # "Pleaded Guilty", "Dismissed" are expected options, but shouldn't show in the list.
      else
        arraignment_outcome = nil
      end
      arrestee_tracking_attributes = {
        incident: incident,
        arrest_id: arrest_id,
        arraigned: arraigned,
        arraignment_outcome: arraignment_outcome
      }
      arrestee_tracking = ArresteeTracking.create!(arrestee_tracking_attributes)
      print "+"
    end
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

        fresh_models = model.from_xml(doc_xml)

        fresh_models.each do |fresh_model|
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
    end

    puts ""
    puts "Imported #{updated_incidents + new_incidents} #{model} records from #{path} in #{time} seconds."
  end
end
