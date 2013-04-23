class Incident
  include Mongoid::Document
  ARREST_PREAMBLE = "arrest_report.e:EnterpriseDatashareDocument.e:DocumentBody.p:NYPDArrestTransaction.p:NYPDArrestReport.p:Arrest"

  embeds_one :arrest_report
  embeds_one :rap_sheet

  field :arrest_id, type: String

  validates :arrest_id, presence: true, uniqueness: true

  scope :arrest_borough, ->(county_code) { where("#{ARREST_PREAMBLE}.p:ArrestLocation.p:LocationCountyCode" => county_code) }
  scope :arrest_charges_include, ->(charge_code) { where("#{ARREST_PREAMBLE}.p:ArrestCharge.p:ChargeClassCode" => charge_code) }
end
