require_relative 'datashare_document'

class RorReport < DatashareDocument
  include Mongoid::Document
  embedded_in :incident

  def arrest_id
    report["n:Arrest"]["j:ActivityID"]["j:ID"]
  end

  def recommendations
    # the to_a ensures that this method always returns an array.
    # singular comments would otherwise be returned as strings.
    report["c:RORInterview"]["j:ActivityCommentText"].to_a
  end

  private

  def report
    body["c:RORInterviewReports"]["c:RORInterviewReport"]
  end
end
