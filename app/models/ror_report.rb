class RorReport
  include Mongoid::Document
  embedded_in :incident

  field :arrest_id, type: String
  validates :arrest_id, presence: true, uniqueness: true

  field :recommendations, type: Array

  before_save :update_incident_attributes

  def self.from_xml(xml_string)
    importer = XMLDocImporter.new(xml_string, "/e:EnterpriseDatashareDocument/e:DocumentBody/c:RORInterviewReports/c:RORInterviewReport")

    arrest_id = importer.attribute_from_xpath("/n:Arrest/j:ActivityID/j:ID")
    ror = RorReport.find_or_initialize_by(arrest_id: arrest_id)
    ror.incident = Incident.find_or_initialize_by(arrest_id: ror.arrest_id)
    recs = importer.attribute_from_xpath("/c:RORInterview/j:ActivityCommentText").to_a
    ror.recommendations = recs.map do |rec|
      rec.capitalize
         .gsub("ror","ROR")
         .gsub("nysid", "NYSID")
         .gsub("fta", "FTA")
    end

    [ror]
  end

  def all_recommendations
    recommendations.join(", ")
  end

  private
  def update_incident_attributes
    incident.update_attributes(recommendations: recommendations)
  end
end
