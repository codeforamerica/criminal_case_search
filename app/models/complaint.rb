class Complaint
  include Mongoid::Document
  embedded_in :incident
  ATTEMPTED_VFOS = %w[120.06 120.07 120.08 120.10 125.25 125.27 135.20
                      140.25 140.30 150.15 160.10 160.15 265.03]
  VFOS = %w[120.02 120.05 120.06 120.07 120.08 120.10 120.11 125.15 125.20
            125.25 125.27 130.53 130.75 130.95 130.96 135.20 140.25 140.30
            150.15 160.10 160.15 215.16 240.55 240.61 263.16 265.03 265.04
            265.08 265.09 265.12 265.13]

  field :arrest_id, type: String
  validates :arrest_id, presence: true, uniqueness: true

  field :top_charge_code, type: String
  validates :top_charge_code, inclusion: { in: %w(I V M F VF), allow_nil: true }

  field :charges, type: Array
  field :complaint_image, type: Moped::BSON::Binary
  field :drug_charge, type: Boolean
  field :misdemeanor_assault_charge, type: Boolean
  field :criminal_contempt_charge, type: Boolean
  field :sex_offense_charge, type: Boolean

  before_save :update_incident_attributes

  def self.from_xml(xml_string)
    importer = XMLDocImporter.new(xml_string, "/soapenv:Envelope/soapenv:Body/nycx:ComplaintXml")

    complaints = []

    defendants = importer.nodes_from_xpath("/next:Defendant")
    defendants.each do |defendant_node|
      arrest_id = defendant_node.xpath("next:DefendantArrest/nc:ActivityIdentification/nc:IdentificationID", importer.namespaces).first.content
      c = Complaint.find_or_initialize_by(arrest_id: arrest_id)

      c.incident = Incident.find_or_initialize_by(arrest_id: c.arrest_id)
      c.charges = defendant_node.xpath("next:ComplaintCharge", importer.namespaces).map do |charge_node|
        charge = { category: charge_node.xpath("j:ChargeCategoryDescriptionText", importer.namespaces).first.content,
                   counts: charge_node.xpath("j:ChargeCountQuantity", importer.namespaces).first.content.to_i,
                   description: charge_node.xpath("j:ChargeDescriptionText", importer.namespaces).first.content,
                   attempted: charge_node.xpath("next:NYCChargeAugmentation/next:ChargeApplicabilityAttemptedIndicator", importer.namespaces).first.content,
                   agency_code: charge_node.xpath("next:NYCChargeAugmentation/next:ChargeAgencyCode", importer.namespaces).first.content
                 }

        if charge[:agency_code] =~ /PL (110\/)220/
          c.drug_charge = true
        end

        if charge[:agency_code] =~ /PL (110\/)120\.00/
          c.misdemeanor_assault_charge = true
        end

        if charge[:agency_code] =~ /PL (110\/)(215.50|215.51|215.52)/
          c.criminal_contempt_charge = true
        end

        if charge[:agency_code] =~ /PL (110\/)130/
          c.sex_offense_charge = true
        end

        charge
      end

      if Complaint.violent_felony_offense?(c.charges.first)
        c.top_charge_code = "VF"
      else
        c.top_charge_code = c.charges.first[:category]
      end

      #c.complaint_image = importer.attribute_from_xpath("/nc:DocumentBinary/nc:BinaryBase64Object") do |b64|
        #tiff_filename = "/tmp/#{c.arrest_id}.tiff"
        #pdf_filename = "/tmp/#{c.arrest_id}.pdf"

        #tiff_data = Base64.decode64(b64)
        #File.open(tiff_filename,"w") do |f|
          #f.write(tiff_data)
        #end

        #`tiff2pdf #{tiff_filename} > #{pdf_filename}`

        #pdf_data = nil
        #File.open(pdf_filename,"r") do |f|
          #pdf_data = f.read
        #end

        #pdf_data
      #end

      complaints << c
    end

    complaints
  end

  def self.violent_felony_offense?(charge)
    if charge[:attempted] == "true"
      ATTEMPTED_VFOS.each do |vfo|
        return true if charge[:agency_code] =~ /PL (110\/)#{Regexp.quote(vfo)}/i
      end
    else
      VFOS.each do |vfo|
        return true if charge[:agency_code] =~ /PL #{Regexp.quote(vfo)}/i
      end
    end
    false
  end

  private
  def update_incident_attributes
    self.incident.update_attribute(:top_charge_code, top_charge_code)
  end
end
