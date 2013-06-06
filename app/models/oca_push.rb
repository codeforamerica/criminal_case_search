require_relative 'datashare_document'

class OcaPush < DatashareDocument
  include Mongoid::Document
  embedded_in :incident

  def arrest_id
    body["o:OCACourtProceedingReport"]["j:Arrest"]["j:ActivityID"]["j:ID"]
  end
end
