require_relative 'datashare_document'

class ArrestReport < DatashareDocument
  include Mongoid::Document
  embedded_in :incident

  before_save :update_incident_defendant_sex
  before_save :update_incident_borough

  def arrest_id
    arrest["j:ActivityID"]["j:ID"]
  end

  def charges
    charges = arrest["p:ArrestCharge"]
    # Sometimes charges don't come through in arrays.
    charges = [charges].flatten
    formatted_charges = charges.map do |charge|
      [charge['p:ChargeClassCode'], charge['j:ChargeStatute']['j:StatuteCodeID']['j:ID']].join(": ")
    end
    formatted_charges.join(", ")
  end

  def person_name
    last_name = arrest["p:ArrestSubject"]["p:Subject"]["j:PersonName"]["j:PersonSurName"]
    given_name = arrest["p:ArrestSubject"]["p:Subject"]["j:PersonName"]["j:PersonGivenName"]
    "#{last_name.titlecase}, #{given_name.titlecase}"
  end

  def defendant_sex
    arrest["p:ArrestSubject"]["p:Subject"]["p:PersonPhysicalDetails"]["p:PersonSexCode"]
  end

  def borough
    arrest["p:ArrestLocation"]["p:LocationCountyCode"]
  end

  private
  def arrest
    body["p:NYPDArrestTransaction"]["p:NYPDArrestReport"]["p:Arrest"]
  end

  def update_incident_defendant_sex
    self.incident.update_attribute(:defendant_sex, defendant_sex)
  end

  def update_incident_borough
    self.incident.update_attribute(:borough, borough)
  end
end
