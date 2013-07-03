class Incident
  include Mongoid::Document
  BOROUGHS = %w(B K M Q S)
  ARREST_PREAMBLE = "arrest_report.e:EnterpriseDatashareDocument.e:DocumentBody.p:NYPDArrestTransaction.p:NYPDArrestReport.p:Arrest"

  embeds_one :arrest_report
  embeds_one :rap_sheet
  embeds_one :complaint
  embeds_one :ror_report
  embeds_one :court_proceeding_report
  embeds_one :arrest_tracking
  embeds_one :docketing_notice

  # Primary key; used to merge all documents. From ArrestReport
  field :arrest_id, type: String
  validates :arrest_id, presence: true, uniqueness: true

  # From ArrestReport
  field :borough, type: String
  validates :borough, inclusion: { in: BOROUGHS, allow_nil: true }
  field :defendant_sex, type: String
  validates :defendant_sex, inclusion: { in: %w(M F), allow_nil: true}

  # From DA's Complaint
  field :top_charge_code, type: String
  validates :top_charge_code, inclusion: { in: %w(I V M F), allow_nil: true }

  scope :borough, ->(county_code) { where(borough: county_code) }
  scope :top_charge, ->(charge_code) { where(:top_charge_code.in => [charge_code].flatten) }
  scope :defendant_sex, ->(sex_code) { where(defendant_sex: sex_code) }
end
