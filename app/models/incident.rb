class Incident
  include Mongoid::Document

  field :arrest_report, type: Hash
  
end
