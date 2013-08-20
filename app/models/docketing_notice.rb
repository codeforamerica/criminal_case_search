class DocketingNotice
  include Mongoid::Document
  embedded_in :incident

  field :arrest_id, type: String
  field :docket_number, type: String
  field :next_court_date, type: Date
  field :next_courthouse, type: String
  field :next_court_part, type: String

  before_save :update_incident_attributes

  def self.from_xml(xml_string)
    importer = XMLDocImporter.new(xml_string, "/soapenv:Envelope/soapenv:Body/xmlns:CaseDocketingNoticeXml")

    arrest_id = importer.attribute_from_xpath("/j:Arrest/nc:ActivityIdentification/nc:IdentificationID").strip
    d = DocketingNotice.find_or_initialize_by(arrest_id: arrest_id)

    d.docket_number = importer.attribute_from_xpath("/ds:Case/nc:CaseDocketID").strip
    next_court_date_string = importer.attribute_from_xpath("/ds:Case/ds:CaseAugmentation/j:CaseCourtEvent/j:CourtEventAppearance/j:CourtAppearanceDate/nc:Date")
    d.next_court_date = Date.parse(next_court_date_string)
    d.next_courthouse = importer.attribute_from_xpath("/ds:Case/ds:CaseAugmentation/j:CaseCourtEvent/j:CourtEventAppearance/j:CourtAppearanceCourt/nc:OrganizationName") do |courthouse_text|
      courthouse_text.strip.gsub("New York City Criminal Court, ","").gsub(" Branch","")
    end
    d.next_court_part = importer.attribute_from_xpath("/ds:Case/ds:CaseAugmentation/j:CaseCourtEvent/j:CourtEventAppearance/j:CourtAppearanceCourt/nc:OrganizationIdentification/nc:IdentificationID").strip
    d.incident = Incident.find_or_initialize_by(arrest_id: d.arrest_id)

    [d]
  end

  private
  def update_incident_attributes
    self.incident.update_attributes(docket_number: docket_number,
                                    next_court_date: next_court_date,
                                    next_court_part: next_court_part,
                                    next_courthouse: next_courthouse)
  end
end
