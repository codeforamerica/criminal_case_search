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
  field :top_charge_types, type: Array, default: []
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
  field :number_of_other_open_cases, type: Integer
  field :prior_conviction_types, type: Array, default: []
  field :prior_conviction_severities, type: Array, default: []
  field :has_failed_to_appear, type: Boolean
  delegate :has_outstanding_bench_warrant?, to: :rap_sheet, allow_nil: true
  delegate :persistent_misdemeanant?, to: :rap_sheet, allow_nil: true
  delegate :on_probation?, to: :rap_sheet, allow_nil: true
  delegate :on_parole?, to: :rap_sheet, allow_nil: true

  # From CJA Report
  field :recommendations, type: Array

  #From ArresteeTracking
  field :arraigned, type: Boolean
  field :arraignment_outcome, type: String

  scope :borough, ->(borough_name) { any_in(borough: borough_name) }
  scope :defendant_sex, ->(sex_code) { where(defendant_sex: sex_code) }
  scope :defendant_age_lte, ->(max_age) { lte(:defendant_age => max_age) }
  scope :defendant_age_gte, ->(min_age) { gte(:defendant_age => min_age) }
  scope :top_charge_in, ->(charge_code) { any_in(:top_charge_code => charge_code) }
  scope :top_charge_types_in, ->(charge_types) { any_in(:top_charge_types => charge_types) }
  scope :has_other_open_cases, gte(number_of_other_open_cases: 1)
  scope :has_no_other_open_cases, any_in(number_of_other_open_cases: [0, nil])
  scope :has_failed_to_appear, where(has_failed_to_appear: true)
  scope :has_not_failed_to_appear, any_in(has_failed_to_appear: [false, nil])
  scope :prior_conviction_types_in, ->(conviction_types) { any_in(:prior_conviction_types => conviction_types.to_a.uniq) }
  scope :prior_conviction_severities_include, ->(severities) { any_in(:prior_conviction_severities => severities.to_a.uniq) }
  scope :prior_conviction_severities_exclude, ->(severities) { nin(:prior_conviction_severities => severities.to_a.uniq) }
  scope :number_of_prior_criminal_convictions_gte, ->(min) { gte(number_of_prior_criminal_convictions: min) }
  scope :number_of_prior_criminal_convictions_lte, ->(max) { lte(number_of_prior_criminal_convictions: max) }
  scope :pre_arraignment, where(next_court_date_is_arraignment: true) # or where arraigned == false
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
