class RorReport
  include Mongoid::Document
  embedded_in :incident

  field :arrest_id, type: String
  field :recommendations, type: String

  def self.from_xml(xml_string)
    importer = XMLDocImporter.new(xml_string, "/e:EnterpriseDatashareDocument/e:DocumentBody/c:RORInterviewReports/c:RORInterviewReport")

    ror = RorReport.new
    ror.arrest_id = importer.attribute_from_xpath("/n:Arrest/j:ActivityID/j:ID")
    ror.incident = Incident.find_or_initialize_by(arrest_id: ror.arrest_id)
    recs = importer.attribute_from_xpath("/c:RORInterview/j:ActivityCommentText").to_a
    ror.recommendations = recs.map do |rec|
      rec.capitalize
         .gsub("ror","ROR")
         .gsub("nysid", "NYSID")
         .gsub("fta", "FTA")
    end.join(", ")

    [ror]
  end
end
