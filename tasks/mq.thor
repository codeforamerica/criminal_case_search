require './config/environment'

class MQ < Thor
  QUEUE_MANAGER = "CJC_QM"

  desc "load_rap_sheets", "Load r Rap Sheets from MQ, if available"
  def load_rap_sheets(n)
    n.to_i.times do
      load_rap_sheet
    end
  end

  desc "load_rap_sheet", "Load one Rap Sheet from MQ, if available"
  def load_rap_sheet
    load_from_queue("SG.CJCCCS.RAPSHEET", RapSheet)
  end

  desc "load_arrest_reports", "Load n Arrest Reports from MQ, if available"
  def load_arrest_reports(n)
    n.to_i.times do
      load_arrest_report
    end
  end

  desc "load_arrest_report", "Load one Arrest Report from MQ, if available"
  def load_arrest_report
    load_from_queue("SG.CJCCCS.ARREST", ArrestReport)
  end


  desc "load_arrestee_trackings", "Load n Arrestee Tracking documents from MQ, if available"
  def load_arrestee_trackings(n)
    n.to_i.times do
      load_arrestee_tracking
    end
  end

  desc "load_arrestee_tracking", "Load one Arrestee Tracking document from MQ, if available"
  def load_arrestee_tracking
    load_from_queue("SG.CJCCCS.ARRESTEE.TRACKING", ArresteeTracking)
  end

  desc "load_docketing_notices", "Load n Docketing Notices from MQ, if available"
  def load_docketing_notices(n)
    n.to_i.times do
      load_docketing_notice
    end
  end

  desc "load_docketing_notice", "Load one Docketing Notice from MQ, if available"
  def load_docketing_notice
    load_from_queue("SG.CJCCCS.CRIMS.DOCKETING", DocketingNotice)
  end

  desc "load_complaints", "Load n Complaints from MQ, if available"
  def load_complaints(n)
    n.to_i.times do
      load_complaint
    end
  end

  desc "load_complaint", "Load one Complaint from MQ, if available"
  def load_complaint
    load_from_queue("SG.CJCCCS.COMPLAINT", Complaint)
  end

  desc "load_ror_reports", "Load n ROR Reports from MQ, if available"
  def load_ror_reports(n)
    n.to_i.times do
      load_ror_report
    end
  end

  desc "load_ror_report", "Load one ROR Report from MQ, if available"
  def load_ror_report
    load_from_queue("SG.CJCCCS.ROR", RorReport)
  end

  private
  def load_from_queue(queue_name, model)
    message = retrieve_message_from_queue(queue_name)
    if message
      persist_message_from_queue(message, model)
    end
  end

  def retrieve_message_from_queue(queue_name)
    WMQ::QueueManager.connect(q_mgr_name: QUEUE_MANAGER) do |qmgr|
      qmgr.open_queue(q_name: queue_name, mode: :input) do |queue|
        message = WMQ::Message.new
        if queue.get(message: message)
          return message.data
        else
          puts "No message available."
          return nil
        end
      end
    end
  end

  def persist_message_from_queue(message, model)
    fresh_models = model.from_xml(message)
    fresh_models.each do |fresh_model|
      incident = Incident.find_or_initialize_by(arrest_id: fresh_model.arrest_id)
      fresh_model.incident = incident
      fresh_model.save!
      puts "Saved #{model.to_s}: #{fresh_model.arrest_id}."
    end
  end
end
