class SoapenvDocument
  private
  def header
    self["soapenv:Envelope"]["soapenv:Header"]
  end

  def body
    self["soapenv:Envelope"]["soapenv:Body"]
  end
end
