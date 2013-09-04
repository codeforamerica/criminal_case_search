class Incident
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_one :arrest_report
  embeds_one :rap_sheet
  embeds_one :complaint
  embeds_one :ror_report
  embeds_one :court_proceeding_report
  embeds_one :arrestee_tracking
  embeds_one :docketing_notice

  # Primary key; used to merge all documents. From ArrestReport
  field :arrest_id, type: String
  validates :arrest_id, presence: true, uniqueness: true

  # From ArrestReport
  field :borough, type: String
  validates :borough, inclusion: { in: ["Brooklyn", "Bronx", "Manhattan", "Queens", "Staten Island"], allow_nil: true }
  field :defendant_sex, type: String
  validates :defendant_sex, inclusion: { in: %w(M F), allow_nil: true}
  field :defendant_age, type: Integer
  validates :defendant_age, numericality: { greater_than_or_equal_to: 0, allow_nil: true}
  delegate :desk_appearance_ticket?, to: :arrest_report, allow_nil: true
  delegate :defendant_name, to: :arrest_report, allow_nil: true

  # From DA's Complaint
  field :top_charge_code, type: String
  validates :top_charge_code, inclusion: { in: %w(I V M F VF), allow_nil: true }
  field :drug_charge, type: Boolean
  field :misdemeanor_assault_charge, type: Boolean
  field :criminal_contempt_charge, type: Boolean
  field :sex_offense_charge, type: Boolean
  delegate :top_charge, to: :complaint, allow_nil: true

  # From OCA Docket
  field :docket_number, type: String
  validates :docket_number, uniqueness: { allow_nil: true }
  field :next_court_date, type: Date #Superceded by OCA Court Action
  field :next_court_date_is_arraignment, type: Boolean
  field :next_court_part, type: String
  field :next_courthouse, type: String

  # From Rap Sheet
  field :number_of_prior_criminal_convictions, type: Integer
  field :has_prior_felony_conviction, type: Boolean
  field :has_prior_violent_felony_conviction, type: Boolean
  field :has_prior_misdemeanor_conviction, type: Boolean
  field :has_prior_drug_conviction, type: Boolean
  field :has_prior_misdemeanor_assault_conviction, type: Boolean
  field :has_prior_criminal_contempt_conviction, type: Boolean
  field :has_prior_sex_offense_conviction, type: Boolean
  field :has_other_open_cases, type: Boolean
  field :has_failed_to_appear, type: Boolean
  delegate :has_outstanding_bench_warrant?, to: :rap_sheet, allow_nil: true
  delegate :persistent_misdemeanant?, to: :rap_sheet, allow_nil: true
  delegate :serving_probation?, to: :rap_sheet, allow_nil: true
  delegate :serving_parole?, to: :rap_sheet, allow_nil: true

  # From CJA Report
  field :recommendations, type: Array

  scope :borough, ->(borough_name) { any_in(borough: borough_name) }
  scope :defendant_sex, ->(sex_code) { where(defendant_sex: sex_code) }
  scope :defendant_age_lte, ->(max_age) { lte(:defendant_age => max_age) }
  scope :defendant_age_gte, ->(min_age) { gte(:defendant_age => min_age) }
  scope :top_charge_in, ->(charge_code) { any_in(:top_charge_code => [charge_code].flatten) }
  scope :has_drug_charge, where(drug_charge: true)
  scope :has_misdemeanor_assault_charge, where(misdemeanor_assault_charge: true)
  scope :has_criminal_contempt_charge, where(criminal_contempt_charge: true)
  scope :has_sex_offense_charge, where(sex_offense_charge: true)
  scope :has_other_open_cases, where(has_other_open_cases: true)
  scope :has_failed_to_appear, where(has_failed_to_appear: true)
  scope :number_of_prior_criminal_convictions_gte, ->(min) { gte(number_of_prior_criminal_convictions: min) }
  scope :number_of_prior_criminal_convictions_lte, ->(max) { lte(number_of_prior_criminal_convictions: max) }
  scope :pre_arraignment, where(next_court_date_is_arraignment: true)
  scope :post_arraignment, ne(next_court_date_is_arraignment: true)
  scope :next_court_date_is, ->(date) { where(next_court_date: date) }
  scope :next_court_date_between, ->(start_date, end_date) { between(next_court_date: start_date...end_date) }

  def charges
    if complaint.present?
      complaint.try(:charges)
    end
  end

  def top_charge_code_expanded
    if top_charge_code == "VF"
      return "Violent Felony"
    elsif top_charge_code == "F"
      return "Felony"
    elsif top_charge_code == "M"
      return "Misdemeanor"
    elsif top_charge_code == "I"
      return "Infraction"
    elsif top_charge_code == "V"
      return "Violation"
    end
    nil
  end
end
