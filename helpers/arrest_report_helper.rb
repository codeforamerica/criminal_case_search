module ArrestReportHelper
  def arrest_report_number(report)
    arrest(report)["j:ActivityID"]["j:ID"]
  end

  def arrest_report_name(report)
    last_name = arrest(report)["p:ArrestSubject"]["p:Subject"]["j:PersonName"]["j:PersonSurName"]
    given_name = arrest(report)["p:ArrestSubject"]["p:Subject"]["j:PersonName"]["j:PersonGivenName"]
    "#{last_name.titlecase}, #{given_name.titlecase}"
  end

  def arrest_report_charge(report)
    charges = arrest(report)["p:ArrestCharge"]
    # Sometimes charges don't come through in arrays.
    charges = [charges].flatten
    formatted_charges = charges.map do |charge|
      begin
        [charge['p:ChargeClassCode'], charge['j:ChargeStatute']['j:StatuteCodeID']['j:ID']].join(": ")
      rescue Exception => e
        binding.pry
      end
    end
    formatted_charges.join(", ")
  end

  private
  def arrest(report)
    report["doc"]["e:EnterpriseDatashareDocument"]["e:DocumentBody"]["p:NYPDArrestTransaction"]["p:NYPDArrestReport"]["p:Arrest"]
  end
end
