class ArresteeTracking
  include Mongoid::Document
  embedded_in :incident

  field :arrest_id, type: String
  validates :arrest_id, presence: true, uniqueness: true

  field :arraigned, type: Boolean
  field :arraignment_outcome, type: String
  field :arraignment_time, type: DateTime

  before_save :update_incident_attributes

  def self.from_xml(xml_string)
    importer = XMLDocImporter.new(xml_string, "/soapenv:Envelope/soapenv:Body/ds:ArresteeTrackingXml")

    arrestee_trackings = []
    arrest_ids = importer.attribute_from_xpath("/j:Arrest/nc:ActivityIdentification/nc:IdentificationID").compact

    arrest_ids.each do |arrest_id|
      at = ArresteeTracking.find_or_initialize_by(arrest_id: arrest_id)
      at.arrest_id = arrest_id
      at.incident = Incident.find_or_initialize_by(arrest_id: at.arrest_id)
      at.arraignment_outcome = importer.attribute_from_xpath("/j:CaseCourtEvent/j:CourtEventAction/nc:ActivityDisposition/nc:DispositionDescriptionText") do |outcome|
        outcome.titleize.gsub("Ror","ROR")
      end

      if at.arraignment_outcome
        at.arraigned = true
        at.arraignment_time = DateTime.parse(importer.attribute_from_xpath("/j:CaseCourtEvent/j:CourtEventAction/nc:ActivityDisposition/nc:DispositionDate/nc:DateTime"))
        arrestee_trackings << at
      end
    end
    arrestee_trackings
  end

  private
  def update_incident_attributes
    incident.update_attributes(arraigned: arraigned,
                               arraignment_outcome: arraignment_outcome)
  end
end
