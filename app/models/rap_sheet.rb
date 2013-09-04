class UnknownRapSheetFormatException < Exception; end

class RapSheet
  include Mongoid::Document
  embedded_in :incident

  field :arrest_id, type: String
  validates :arrest_id, presence: true, uniqueness: true

  # Supercedes Arrest Report
  field :defendant_age, type: Integer
  validates :defendant_age, numericality: { greater_than_or_equal_to: 0, allow_nil: true}
  field :defendant_sex, type: String
  validates :defendant_sex, inclusion: { in: %w(M F), allow_nil: true}

  field :number_of_prior_criminal_convictions, type: Integer
  field :has_prior_felony_conviction, type: Boolean
  field :has_prior_violent_felony_conviction, type: Boolean
  field :has_prior_misdemeanor_conviction, type: Boolean
  field :has_other_open_cases, type: Boolean
  field :has_failed_to_appear, type: Boolean

  field :has_prior_drug_conviction, type: Boolean
  field :has_prior_misdemeanor_assault_conviction, type: Boolean
  field :has_prior_criminal_contempt_conviction, type: Boolean
  field :has_prior_sex_offense_conviction, type: Boolean

  field :has_outstanding_bench_warrant, type: Boolean #Todo
  field :persistent_misdemeanant, type: Boolean
  field :serving_probation, type: Boolean
  field :serving_parole, type: Boolean

  before_save :update_incident_attributes

  def self.from_xml(xml_string)
    importer = XMLDocImporter.new(xml_string, "/e:EnterpriseDatashareDocument/e:DocumentBody/ds:RapSheetExchange/ds:rapSheet/ds:attachment/ds:content")

    rapsheets = []
    if importer.namespaces.keys.include?("xmlns:nysRap")
      includes_summary = true if importer.nodes_from_xpath("/nysRap:NewYorkStateRapSheet/nys:NewYorkStateResponsePrimary/nys:Summary").present?

      if includes_summary
        arrest_id = importer.attribute_from_xpath("/nysRap:NewYorkStateRapSheet/nys:TransactionData/nys:Arrest/nc:ActivityIdentification/nc:IdentificationID")
        rs = RapSheet.find_or_initialize_by(arrest_id: arrest_id)
        rs.incident = Incident.find_or_initialize_by(arrest_id: rs.arrest_id)

        defendant_dob = importer.attribute_from_xpath("/nysRap:NewYorkStateRapSheet/nys:NewYorkStateResponsePrimary/nys:AccumulatedPersonInformation/nc:PersonBirthDate/nc:Date").to_a.first
        rs.defendant_age = RapSheet.age_from_dob(Date.parse(defendant_dob))
        rs.defendant_sex = importer.attribute_from_xpath("/nysRap:NewYorkStateRapSheet/nys:NewYorkStateResponsePrimary/nys:AccumulatedPersonInformation/nc:PersonSexText").to_a.first[0]

        summary_node = importer.nodes_from_xpath("/nysRap:NewYorkStateRapSheet/nys:NewYorkStateResponsePrimary/nys:Summary")

        felony = summary_node.xpath("nys:SummaryCounts[@type='Conviction']/nys:Count[@type='Felony']/nys:Value", importer.namespaces).first.content.to_i
        violent_felony = summary_node.xpath("nys:SummaryCounts[@type='Conviction']/nys:Count[@type='ViolentFelony']/nys:Value", importer.namespaces).first.content.to_i
        misdemeanor = summary_node.xpath("nys:SummaryCounts[@type='Conviction']/nys:Count[@type='Misdemeanor']/nys:Value", importer.namespaces).first.content.to_i

        rs.has_prior_felony_conviction = RapSheet.boolean_from_int(felony)
        rs.has_prior_violent_felony_conviction = RapSheet.boolean_from_int(violent_felony)
        rs.has_prior_misdemeanor_conviction = RapSheet.boolean_from_int(misdemeanor)
        rs.number_of_prior_criminal_convictions = felony + misdemeanor

        other_open_cases = summary_node.xpath("nys:SummaryCounts[@type='OpenCases']/nys:TotalCount", importer.namespaces).first.content.to_i
        rs.has_other_open_cases = RapSheet.boolean_from_int(other_open_cases)

        fta = summary_node.xpath("nys:SummaryCounts[@type='Warrant']/nys:Count[@type='FailureToAppear']/nys:Value", importer.namespaces).first.content.to_i
        rs.has_failed_to_appear = RapSheet.boolean_from_int(fta)

        previous_convictions = importer.nodes_from_xpath("/nysRap:NewYorkStateRapSheet/nys:NewYorkStateResponsePrimary/nys:CriminalCycle/nys:CourtCaseCycle/nys:Disposition/nys:DispositionCodedCharge")
        previous_convictions.each do |conviction|
          title = conviction.xpath("nys:CodedStatute/nys:StatuteTitleText", importer.namespaces).first.content
          code_section = conviction.xpath("nys:CodedStatute/j:StatuteCodeSectionIdentification/nc:IdentificationID", importer.namespaces).first.try(:content)
          # A = Attempted; C = Completed
          #attempted_code = conviction.xpath("nys:ChargeAttemptedCompletedText", importer.namespaces).first.content

          if title == "PL" and code_section =~ /220/
            rs.has_prior_drug_conviction = true
          end

          if title == "PL" and code_section =~ /120\.00/
            rs.has_prior_misdemeanor_assault_conviction = true
          end

          if title == "PL" and code_section =~ /215.50|215.51|215.52/
            rs.has_prior_criminal_contempt_conviction = true
          end

          if title == "PL" and code_section =~ /130/
            rs.has_prior_sex_offense_conviction = true
          end
        end

        if importer.nodes_from_xpath("/nysRap:NewYorkStateRapSheet/nys:NewYorkStateResponsePrimary/nys:Banner[@s:id='8']").present?
          rs.persistent_misdemeanant = true
        end

        if importer.nodes_from_xpath("/nysRap:NewYorkStateRapSheet/nys:NewYorkStateResponsePrimary/nys:Banner[@s:id='46']").present?
          rs.serving_parole = true
        end

        if importer.nodes_from_xpath("/nysRap:NewYorkStateRapSheet/nys:NewYorkStateResponsePrimary/nys:Banner[@s:id='43']").present?
          rs.serving_probation = true
        end
        rapsheets << rs
      else
        # Ignoring rap sheets without summaries.
      end
    elsif importer.namespaces.keys.include?("xmlns:nysIIIRap")
      # rs.arrest_id = importer.attribute_from_xpath("/nysIIIRap:IIILateResponse/nys:TransactionData/nys:Arrest/nc:ActivityIdentification/nc:IdentificationID")
      # TODO: Ignoring interstate rap sheets.
    elsif importer.namespaces.keys.include?("xmlns:nysNCICRap")
      # rs.arrest_id = importer.attribute_from_xpath("/nysNCICRap:NCICLateResponse/nys:TransactionData/nys:Arrest/nc:ActivityIdentification/nc:IdentificationID")
      # TODO: Ignoring NCIC rap sheets.
    else
      raise UnknownRapSheetFormatException
    end

    rapsheets
  end

  private
  def self.age_from_dob(dob)
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def self.boolean_from_int(int)
    int > 0 ? true : false
  end

  def update_incident_attributes
    incident.update_attributes(defendant_age: defendant_age,
                               defendant_sex: defendant_sex,
                               number_of_prior_criminal_convictions: number_of_prior_criminal_convictions,
                               has_prior_felony_conviction: has_prior_felony_conviction,
                               has_prior_violent_felony_conviction: has_prior_violent_felony_conviction,
                               has_prior_misdemeanor_conviction: has_prior_misdemeanor_conviction,
                               has_prior_drug_conviction: has_prior_drug_conviction,
                               has_prior_misdemeanor_assault_conviction: has_prior_misdemeanor_assault_conviction,
                               has_prior_criminal_contempt_conviction: has_prior_criminal_contempt_conviction,
                               has_prior_sex_offense_conviction: has_prior_sex_offense_conviction,
                               has_other_open_cases: has_other_open_cases,
                               has_failed_to_appear: has_failed_to_appear)
  end
end
