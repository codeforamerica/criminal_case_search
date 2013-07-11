require_relative 'soapenv_document'

class DocketingNotice < SoapenvDocument
  include Mongoid::Document
  embedded_in :incident

  before_save :update_incident_attributes

  def arrest_id
    notice["j:Arrest"]["nc:ActivityIdentification"]["nc:IdentificationID"].strip
  end

  def docket_number
    notice["ds:Case"]["nc:CaseDocketID"].strip
  end

  def next_court_date
    Date.parse(notice["ds:Case"]["ds:CaseAugmentation"]["j:CaseCourtEvent"]["j:CourtEventAppearance"]["j:CourtAppearanceDate"]["nc:Date"])
  end

  def next_court_part
    court = notice["ds:Case"]["ds:CaseAugmentation"]["j:CaseCourtEvent"]["j:CourtEventAppearance"]["j:CourtAppearanceCourt"]["nc:OrganizationName"].strip
    part = notice["ds:Case"]["ds:CaseAugmentation"]["j:CaseCourtEvent"]["j:CourtEventAppearance"]["j:CourtAppearanceCourt"]["nc:OrganizationIdentification"]["nc:IdentificationID"].strip
    formatted_court = court.gsub("New York City Criminal Court, ","").gsub(" Branch","")
    [formatted_court, part].join(": ")
  end

  private

  def notice
    body["CaseDocketingNoticeXml"]
  end

  def update_incident_attributes
    self.incident.update_attributes(:docket_number => docket_number, :next_court_date => next_court_date, :next_court_part => next_court_part)
  end
end
