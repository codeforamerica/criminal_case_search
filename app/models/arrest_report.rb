require_relative 'datashare_document'

class ArrestReport < DatashareDocument
  include Mongoid::Document
  embedded_in :incident

  def arrest
    self.body["p:NYPDArrestTransaction"]["p:NYPDArrestReport"]["p:Arrest"]
  end

  def arrest_id
    self.arrest["j:ActivityID"]["j:ID"]
  end
end
