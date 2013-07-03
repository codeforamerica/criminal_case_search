require_relative 'datashare_document'

class CourtProceedingReport < DatashareDocument
  include Mongoid::Document
  embedded_in :incident

  def arrest_id
    report["j:Arrest"]["j:ActivityID"]["j:ID"]
  end

  private
  def report
    body["o:OCACourtProceedingReport"]
  end
end
