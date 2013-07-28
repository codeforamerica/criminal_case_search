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
  
  def borough
    arrest_id[0]
  end

  def defendant_age
    RapSheet.age(Date.parse(rap_sheet["ds:identity"]["ds:arresteeDob"]))
  end

  def defendant_sex
    #binding.pry
    if rap_sheet["ds:attachment"]["ds:content"]["nysRap:NewYorkStateRapSheet"]
      rap_sheet["ds:attachment"]["ds:content"]["nysRap:NewYorkStateRapSheet"]["nys:TransactionData"]["nys:TransactionSubjectReference"]["nc:PersonSexText"][0]
    else
      nil
    end
  end

  def charges
    if rap_sheet["ds:attachment"]["ds:content"]["nysRap:NewYorkStateRapSheet"]
      charge_or_charges = rap_sheet.try {|rs| rs["ds:attachment"]["ds:content"]["nysRap:NewYorkStateRapSheet"]["nys:TransactionData"]["nys:Arrest"]["nys:CodedCharge"] }
      [charge_or_charges].flatten
    else
      []
    end
  end
  
  def charge_info
    #binding.pry
    charges.map do |c|
      statue_title = c["nys:CodedStatute"]["nys:StatuteTitleText"]
      statue_section = c["nys:CodedStatute"]["j:StatuteCodeSectionIdentification"]["nc:IdentificationID"]
      statue_subsection = c["nys:CodedStatute"]["nys:StatuteCodeSubSectionIdentification"]["nc:IdentificationID"]
      formatted_statue = ""
      formatted_statue += statue_title
      formatted_statue += " "
      formatted_statue += statue_section if statue_section
      #formatted_statue += statue_subsection if statue_subsection

      {
        description: c["nys:CodedStatute"]["j:StatuteDescriptionText"],
        counts: c["j:ChargeCountQuantity"].to_i,
        agency_code: formatted_statue
      }
    end
  end

  def top_charge_code
    charges[0].try { |charge| charge["j:ChargeCategoryDescriptionText"][0] }
  end

  private
  def self.age(dob)
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def rap_sheet
    body["ds:RapSheetExchange"]["ds:rapSheet"]
  end
end
