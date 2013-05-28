require_relative 'soapenv_document'

class Complaint < SoapenvDocument
  include Mongoid::Document
  embedded_in :incident

  def arrest_ids
    [complaint["next:Defendant"]].flatten.map { |d| d["next:DefendantArrest"]["nc:ActivityIdentification"]["nc:IdentificationID"]}
  end

  private
  def complaint
    body["nycx:ComplaintXml"]
  end
end
