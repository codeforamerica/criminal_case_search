class Incident
  include Mongoid::Document

  embeds_one :arrest_report
  embeds_one :rap_sheet

  field :arrest_id, type: String

  validates :arrest_id, presence: true, uniqueness: true
end
