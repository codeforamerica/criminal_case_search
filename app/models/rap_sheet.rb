require_relative 'datashare_document'

class RapSheet < DatashareDocument
  include Mongoid::Document
  embedded_in :incident

  def arrest_id
    self.body["ds:RapSheetExchange"]["ds:rapSheet"]["ds:identity"]["ds:arrestId"]
  end
end
