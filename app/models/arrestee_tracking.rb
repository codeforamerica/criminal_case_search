require_relative 'datashare_document'

class ArresteeTracking < DatashareDocument
  include Mongoid::Document
  embedded_in :incident

  field :arrest_id, type: String

  def self.from_xml(xml_string)
    importer = XMLDocImporter.new(xml_string, "/soapenv:Envelope/soapenv:Body/ds:ArresteeTrackingXml")

    arrestee_trackings = []
    arrest_ids = importer.attribute_from_xpath("/j:Arrest/nc:ActivityIdentification/nc:IdentificationID").compact

    # TODO: There are separate arrest IDS for ARR_ID and LEAD_ARR_ID. Should we choose one instead of both?
    arrest_ids.each do |arrest_id|
      at = ArresteeTracking.new
      at.arrest_id = arrest_id
      at.incident = Incident.find_or_initialize_by(arrest_id: at.arrest_id)
      arrestee_trackings << at
    end

    arrestee_trackings
  end
end
