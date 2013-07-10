require_relative 'soapenv_document'

class DocketingNotice < SoapenvDocument
  include Mongoid::Document
  embedded_in :incident

  def arrest_id
    notice["j:Arrest"]["nc:ActivityIdentification"]["nc:IdentificationID"].strip
  end

  def docket_number
    notice["ds:Case"]["nc:CaseDocketID"].strip
  end

  private

  def notice
    body["CaseDocketingNoticeXml"]
  end

  def update_incident_attributes
    self.incident.update_attribute(:docket_number, docket_number)
  end
end
