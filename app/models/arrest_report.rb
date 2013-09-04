class ArrestReport
  include Mongoid::Document

  embedded_in :incident

  field :arrest_id, type: String
  validates :arrest_id, presence: true, uniqueness: true

  field :defendant_first_name, type: String
  field :defendant_last_name, type: String
  field :defendant_sex, type: String
  validates :defendant_sex, inclusion: { in: %w(M F), allow_nil: true}

  field :defendant_age, type: Integer
  validates :defendant_age, numericality: { greater_than_or_equal_to: 0, allow_nil: true}

  field :borough, type: String
  validates :borough, inclusion: { in: ["Brooklyn", "Bronx", "Manhattan", "Queens", "Staten Island"], allow_nil: true }

  field :precinct, type: String
  field :desk_appearance_ticket, type: Boolean
  field :desk_appearance_ticket_court_date, type: Date

  before_save :update_incident_attributes

  def self.from_xml(xml_string)
    importer = XMLDocImporter.new(xml_string, "/e:EnterpriseDatashareDocument/e:DocumentBody/p:NYPDArrestTransaction/p:NYPDArrestReport")

    arrest_id = importer.attribute_from_xpath("/p:Arrest/j:ActivityID/j:ID")
    ar = ArrestReport.find_or_initialize_by(arrest_id: arrest_id)

    ar.borough = importer.attribute_from_xpath("/p:Arrest/p:ArrestComplaint/p:ComplaintRecordedLocation/j:LocationAddress/j:LocationCityName", &:titleize)
    ar.precinct = importer.attribute_from_xpath("/p:Arrest/p:ArrestLocation/j:LocationLocale/j:LocalePoliceJurisdictionID/j:ID")
    ar.defendant_first_name = importer.attribute_from_xpath("/p:Arrest/p:ArrestSubject/p:Subject/j:PersonName/j:PersonGivenName", &:titleize)
    ar.defendant_last_name = importer.attribute_from_xpath("/p:Arrest/p:ArrestSubject/p:Subject/j:PersonName/j:PersonSurName", &:titleize)
    ar.defendant_sex = importer.attribute_from_xpath("/p:Arrest/p:ArrestSubject/p:Subject/p:PersonPhysicalDetails/p:PersonSexCode")
    ar.defendant_age = importer.attribute_from_xpath("/p:Arrest/p:ArrestSubject/p:Subject/p:PersonAge")
    ar.desk_appearance_ticket = importer.attribute_from_xpath("/p:DeskAppearanceTicketData/p:DeskAppearanceTicketID/j:ID") { |dat_id| dat_id == "000000000" ? false : true }
    if ar.desk_appearance_ticket == true
      ar.desk_appearance_ticket_court_date = Date.parse(importer.attribute_from_xpath("/p:DeskAppearanceTicketData/p:DeskAppearanceInitialCourtDate"))
    end

    ar.incident = Incident.find_or_initialize_by(arrest_id: ar.arrest_id)

    [ar]
  end

  def defendant_name
    "#{defendant_last_name}, #{defendant_first_name}"
  end

  private
  def update_incident_attributes
    incident.update_attributes(defendant_sex: defendant_sex, borough: borough, defendant_age: defendant_age)
    if desk_appearance_ticket?
      #Todo: which court part?
      incident.update_attributes(next_court_date: desk_appearance_ticket_court_date)
    end
  end
end
