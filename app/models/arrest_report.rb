require_relative 'xml_doc_importer'

class ArrestReport
  include Mongoid::Document

  embedded_in :incident

  field :arrest_id, type: String
  field :defendant_first_name, type: String
  field :defendant_last_name, type: String
  field :defendant_sex, type: String
  field :defendant_age, type: Integer
  field :borough, type: String
  field :precinct, type: String
  field :desk_appearance_ticket, type: Boolean

  before_save :update_incident_attributes

  def self.from_xml(xml_string)
    importer = XMLDocImporter.new(xml_string, "/e:EnterpriseDatashareDocument/e:DocumentBody/p:NYPDArrestTransaction/p:NYPDArrestReport")

    ar = ArrestReport.new
    ar.arrest_id = importer.attribute_from_xpath("/p:Arrest/j:ActivityID/j:ID")
    ar.borough = importer.attribute_from_xpath("/p:Arrest/p:ArrestComplaint/p:ComplaintRecordedLocation/j:LocationAddress/j:LocationCityName", &:titleize)
    ar.precinct = importer.attribute_from_xpath("/p:Arrest/p:ArrestLocation/j:LocationLocale/j:LocalePoliceJurisdictionID/j:ID")
    ar.defendant_first_name = importer.attribute_from_xpath("/p:Arrest/p:ArrestSubject/p:Subject/j:PersonName/j:PersonGivenName", &:titleize)
    ar.defendant_last_name = importer.attribute_from_xpath("/p:Arrest/p:ArrestSubject/p:Subject/j:PersonName/j:PersonSurName", &:titleize)
    ar.defendant_sex = importer.attribute_from_xpath("/p:Arrest/p:ArrestSubject/p:Subject/p:PersonPhysicalDetails/p:PersonSexCode")
    ar.defendant_age = importer.attribute_from_xpath("/p:Arrest/p:ArrestSubject/p:Subject/p:PersonAge")
    ar.desk_appearance_ticket = importer.attribute_from_xpath("/p:DeskAppearanceTicketData/p:DeskAppearanceTicketID/j:ID") { |dat_id| dat_id == "000000000" ? false : true }

    [ar]
  end

  def defendant_name
    "#{defendant_last_name}, #{defendant_first_name}"
  end

  private
  def update_incident_attributes
    self.incident.update_attributes(defendant_sex: defendant_sex, borough: borough, defendant_age: defendant_age)
  end
end
