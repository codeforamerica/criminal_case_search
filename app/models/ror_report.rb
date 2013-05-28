require_relative 'datashare_document'

class RorReport < DatashareDocument
  include Mongoid::Document
  embedded_in :incident

  def arrest_id
    report["n:Arrest"]["j:ActivityID"]["j:ID"]
  end

  private
  def report
    body["c:RORInterviewReports"]["c:RORInterviewReport"]
  end
end
