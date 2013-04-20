class DatashareDocument
  def header
    self["e:EnterpriseDatashareDocument"]["e:DocumentHeader"]
  end

  def body
    self["e:EnterpriseDatashareDocument"]["e:DocumentBody"]
  end
end
