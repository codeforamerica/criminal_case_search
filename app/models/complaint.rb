require_relative 'soapenv_document'

class Complaint < SoapenvDocument
  include Mongoid::Document
  embedded_in :incident

  before_save :update_incident_attributes

  def defendants
    [complaint["next:Defendant"]].flatten
  end

  def defendant_for_incident
    # Original version:
    #defendants.select { |d| d["next:DefendantArrest"]["nc:ActivityIdentification"]["nc:IdentificationID"] == incident.arrest_id }.first
    # Hacky version: used to fake data packages
    defendants.first
  end

  def arrest_ids
    defendants.map { |d| d["next:DefendantArrest"]["nc:ActivityIdentification"]["nc:IdentificationID"]}
  end

  def charges
    [defendant_for_incident["next:ComplaintCharge"]].flatten
  end

  def charge_info
    charges.map do |c|
      {
        description: c["j:ChargeDescriptionText"],
        counts: c["j:ChargeCountQuantity"].to_i,
        agency_code: c["next:NYCChargeAugmentation"]["next:ChargeAgencyCode"]
      }
    end
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

  def update_incident_attributes
    self.incident.update_attribute(:top_charge_code, top_charge_code)
  end
end
