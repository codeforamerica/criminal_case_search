require_relative 'xml_doc_importer'

class Complaint
  include Mongoid::Document
  embedded_in :incident

  field :arrest_id, type: String
  field :top_charge_code, type: String
  field :charges, type: Array
  field :complaint_image, type: Moped::BSON::Binary

  before_save :update_incident_attributes

  def self.from_xml(xml_string)
    importer = XMLDocImporter.new(xml_string, "/soapenv:Envelope/soapenv:Body/nycx:ComplaintXml")

    complaints = []

    defendants = importer.nodes_from_xpath("/next:Defendant")
    defendants.each do |defendant_node|
      c = Complaint.new
      c.arrest_id = defendant_node.xpath("next:DefendantArrest/nc:ActivityIdentification/nc:IdentificationID", importer.namespaces).first.content
      c.incident = Incident.find_or_initialize_by(arrest_id: c.arrest_id)
      c.charges = defendant_node.xpath("next:ComplaintCharge", importer.namespaces).map do |charge|
        { category: charge.xpath("j:ChargeCategoryDescriptionText", importer.namespaces).first.content,
          counts: charge.xpath("j:ChargeCountQuantity", importer.namespaces).first.content.to_i,
          description: charge.xpath("j:ChargeDescriptionText", importer.namespaces).first.content,
          attempted: charge.xpath("next:NYCChargeAugmentation/next:ChargeApplicabilityAttemptedIndicator", importer.namespaces).first.content,
          agency_code: charge.xpath("next:NYCChargeAugmentation/next:ChargeAgencyCode", importer.namespaces).first.content
        }
      end
      c.top_charge_code = c.charges.first[:category]

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


  private
  def update_incident_attributes
    self.incident.update_attribute(:top_charge_code, top_charge_code)
  end
end
