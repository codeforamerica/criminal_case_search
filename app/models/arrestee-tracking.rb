require_relative 'datashare_document'

class ArresteeTracking < DatashareDocument
  include Mongoid::Document
  embedded_in :incident

  def arrest_id
    body["ds:ArresteeTrackingXml"]["j:Arrest"]["nc:ActivityIdentification"]["nc:IdentificationID"]
  end

  private
  
  def body
    self["soapenv:Envelope"]["soapenv:Body"]
  end

  def header
    self["soapenv:Envelope"]["soapenv:Header"]
  end
end
