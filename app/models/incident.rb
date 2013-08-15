class Incident
  include Mongoid::Document

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
  validates :borough, inclusion: { in: %w(B K M Q S), allow_nil: true }
  field :defendant_sex, type: String
  validates :defendant_sex, inclusion: { in: %w(M F), allow_nil: true}
  field :defendant_age, type: Integer
  validates :defendant_age, numericality: { greater_than_or_equal_to: 0, allow_nil: true}

  # From DA's Complaint
  field :top_charge_code, type: String
  validates :top_charge_code, inclusion: { in: %w(I V M F), allow_nil: true }

  # From OCA Docket
  field :docket_number, type: String
  #validates :docket_number, uniqueness: { allow_nil: true }

  field :next_court_date, type: Date
  field :next_court_part, type: String

  scope :borough, ->(county_code) { where(:borough.in => county_code) }
  scope :top_charge, ->(charge_code) { where(:top_charge_code.in => [charge_code].flatten) }
  scope :defendant_sex, ->(sex_code) { where(defendant_sex: sex_code) }
  scope :defendant_age_lte, ->(max_age) { where(:defendant_age.lte => max_age) }
  scope :defendant_age_gte, ->(min_age) { where(:defendant_age.gte => min_age) }

  def charges
    if complaint.present?
      complaint.try(:charge_info)
    else
      rap_sheet.try(:charge_info)
    end
  end

  def top_charge_code_expanded
    if top_charge_code == "F"
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
