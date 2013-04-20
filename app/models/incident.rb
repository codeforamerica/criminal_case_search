class Incident
  include Mongoid::Document

  embeds_one :arrest_report

  field :arrest_id, type: String

  validates :arrest_id, presence: true, uniqueness: true
end
