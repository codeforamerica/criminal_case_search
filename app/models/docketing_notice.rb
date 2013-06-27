require_relative 'soapenv_document'

class DocketingNotice < SoapenvDocument
  include Mongoid::Document
  embedded_in :incident

  def arrest_id
    notice["j:Arrest"]["nc:ActivityIdentification"]["nc:IdentificationID"].strip
  end

  private
  def notice
    body["CaseDocketingNoticeXml"]
  end
end
