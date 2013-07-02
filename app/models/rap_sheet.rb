require_relative 'datashare_document'

class RapSheet < DatashareDocument
  include Mongoid::Document
  embedded_in :incident

  def body_proxy
    body
  end

  def arrest_id
    body["ds:RapSheetExchange"]["ds:rapSheet"]["ds:identity"]["ds:arrestId"]
  end
end
