class IncidentFilter

  def self.scope(params)
    scope = Incident.scoped

    if params[:borough]
      borough_names = params[:borough].map {|code| DatashareFilter::BOROUGH_CODES_TO_NAMES[code]}
      scope = scope.borough(borough_names)
    end

    if params["top_charge"]
      if params["top_charge"] == "VI"
        params["top_charge"] = %w(I V)
      end
      unless params["top_charge"] == "A"
        scope = scope.top_charge_in(params["top_charge"])
      end
    end

    if params["include_charge"]
      if params["include_charge"].include? "D"
        scope = scope.has_drug_charge
      end
      if params["include_charge"].include? "MA"
        scope = scope.has_misdemeanor_assault_charge
      end
      if params["include_charge"].include? "CC"
        scope = scope.has_criminal_contempt_charge
      end
      if params["include_charge"].include? "SO"
        scope = scope.has_sex_offense_charge
      end
      #if params["include_charge"].include? "AA"
        #scope = scope.has_untracked_charge
      #end
    end

    if params["sex"]
      unless params["sex"] == "A"
        scope = scope.defendant_sex(params["sex"])
      end
    end

    if params["min_age"].present?
      scope = scope.defendant_age_gte(params["min_age"])
    end

    if params["max_age"].present?
      scope = scope.defendant_age_lte(params["max_age"])
    end

    if params["open_cases"]
      if params["open_cases"] == "Y"
        scope = scope.has_other_open_cases
      elsif params["open_cases"] == "N"
        scope = scope.has_no_other_open_cases
      end
    end

    if params["failed_to_appear"]
      if params["failed_to_appear"] == "Y"
        scope = scope.has_failed_to_appear
      elsif params["failed_to_appear"] == "N"
        scope = scope.has_not_failed_to_appear
      end
    end

   if params["prior_convictions"]
      if params["prior_convictions"].include? "D"
        scope = scope.has_prior_drug_conviction
      end
      if params["prior_convictions"].include? "MA"
        scope = scope.has_prior_misdemeanor_assault_conviction
      end
      if params["prior_convictions"].include? "CC"
        scope = scope.has_prior_criminal_contempt_conviction
      end
      if params["prior_convictions"].include? "SO"
        scope = scope.has_prior_sex_offense_conviction
      end
      #if params["prior_convictions"].include? "AA"
        #scope = scope.has_prior_untracked_charge
      #end
    end

    if params["number_of_prior_convictions"]
      if params["prior_conviction_bounds"] == "more"
        scope = scope.number_of_prior_criminal_convictions_gte(params["number_of_prior_convictions"])
      elsif params["prior_conviction_bounds"] == "fewer"
        scope = scope.number_of_prior_criminal_convictions_lte(params["number_of_prior_convictions"])
      end
    end

    if params["appearance_type"]
      if params["appearance_type"] == "arr"
        scope = scope.pre_arraignment
      elsif params["appearance_type"] == "post-arr"
        scope = scope.post_arraignment
      end
    end

    if params["next_court_date"]
      if params["next_court_date"] == "today"
        scope = scope.next_court_date_is(Date.today)
      elsif params["next_court_date"] == "tomorrow"
        scope = scope.next_court_date_is(Date.tomorrow)
      elsif params["next_court_date"] == "7-day"
        scope = scope.next_court_date_between(Date.today, Date.today + 7.days)
      end
    end

    scope
  end
end
