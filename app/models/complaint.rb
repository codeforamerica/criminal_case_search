require_relative 'soapenv_document'

class Complaint < SoapenvDocument
  include Mongoid::Document
  embedded_in :incident

  before_save :update_incident_top_charge_code

  def defendants
    [complaint["next:Defendant"]].flatten
  end

  def defendant_for_incident
    defendants.select { |d| d["next:DefendantArrest"]["nc:ActivityIdentification"]["nc:IdentificationID"] == incident.arrest_id }.first
  end

  def arrest_ids
    defendants.map { |d| d["next:DefendantArrest"]["nc:ActivityIdentification"]["nc:IdentificationID"]}
  end

  def charges
    [defendant_for_incident["next:ComplaintCharge"]].flatten
  end

  def top_charge
    charges.first
  end

  def top_charge_code
    top_charge["j:ChargeCategoryDescriptionText"]
  end

  private
  def complaint
    body["nycx:ComplaintXml"]
  end

  def update_incident_top_charge_code
    self.incident.update_attribute(:top_charge_code, top_charge_code)
  end
end
