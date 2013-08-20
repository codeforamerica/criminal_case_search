class CourtProceedingReport
  include Mongoid::Document
  embedded_in :incident

  field :arrest_id, type: String
  validates :arrest_id, presence: true, uniqueness: true

  def self.from_xml(xml_string)
    importer = XMLDocImporter.new(xml_string, "/e:EnterpriseDatashareDocument/e:DocumentBody/o:OCACourtProceedingReport")

    arrest_id = importer.attribute_from_xpath("/j:Arrest/j:ActivityID/j:ID")
    if arrest_id.present?
      cpr = CourtProceedingReport.find_or_initialize_by(arrest_id: arrest_id)
      cpr.incident = Incident.find_or_initialize_by(arrest_id: cpr.arrest_id)
      #TODO: Save other data

      [cpr]
    else
      []
    end
  end
end
