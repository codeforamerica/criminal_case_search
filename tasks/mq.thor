require './config/environment'

class MQ < Thor
  QUEUE_MANAGER = "CJC_QM"

  desc "load_rap_sheet", "Load one Rap Sheet from MQ, if available"
  def load_rap_sheet
    load_from_queue("SG.CJCCCS.RAPSHEET", RapSheet)
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
          return message
        else
          puts "No message available."
        end
      end
    end
  end

  def persist_message_from_queue(message, model)
    fresh_models = model.from_xml(doc_xml)
    fresh_models.each do |fresh_model|
      incident = Incident.find_or_initialize_by(arrest_id: fresh_model.arrest_id)
      fresh_model.incident = incident
      fresh_model.save!
    end
  end
end
