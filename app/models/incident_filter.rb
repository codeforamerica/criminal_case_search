class IncidentFilter

  def self.scope(params)
    scope = Incident.scoped

    if params[:borough]
      borough_names = params[:borough].map {|code| DatashareFilter::BOROUGH_CODES_TO_NAMES[code]}
      scope = scope.borough(borough_names)
    end

    if params["top_charge"]
      top_charge = params["top_charge"].map { |el| el == "VI" ? ["V", "I"] : el}.flatten
      scope = scope.top_charge_in(top_charge.flatten)
    end

    if params["include_charge"]
      top_charge_types = []
      if params["include_charge"].include? "D"
        top_charge_types << "Drug"
      end
      if params["include_charge"].include? "MA"
        top_charge_types << "Misdemeanor Assault"
      end
      if params["include_charge"].include? "CC"
        top_charge_types << "Criminal Contempt"
      end
      if params["include_charge"].include? "SO"
        top_charge_types << "Sex Offense"
      end
      if params["include_charge"].include? "A"
        top_charge_types << "Untracked"
        top_charge_types << []
      end
      scope = scope.top_charge_types_in(top_charge_types)
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

    if params["parole_or_probation"]
      if params["parole_or_probation"] == "Y"
        scope = scope.is_on_parole_or_probation
      elsif params["parole_or_probation"] == "N"
        scope = scope.is_not_on_parole_or_probation
      end
    end

    if params["prior_convictions"]
      conviction_types = []
      if params["prior_convictions"].include? "D"
        conviction_types << "Drug"
      end
      if params["prior_convictions"].include? "MA"
        conviction_types << "Misdemeanor Assault"
      end
      if params["prior_convictions"].include? "CC"
        conviction_types << "Criminal Contempt"
      end
      if params["prior_convictions"].include? "SO"
        conviction_types << "Sex Offense"
      end
      if params["prior_convictions"].include? "A"
        conviction_types << "Untracked"
        conviction_types << []
      end

      scope = scope.prior_conviction_types_in(conviction_types)
    end

    if params["prior_convicion_severity"]
      exclude_severities = []

      exclude_severities << "Violent Felony" unless params["prior_convicion_severity"].include? "VF"
      exclude_severities << "Felony" unless params["prior_convicion_severity"].include? "F"
      exclude_severities << "Misdemeanor" unless params["prior_convicion_severity"].include? "M"

      scope = scope.prior_conviction_severities_exclude(exclude_severities) if exclude_severities.present?
    end

    if params["number_of_prior_convictions"]
      if params["prior_conviction_bounds"] == "more"
        scope = scope.number_of_prior_criminal_convictions_gte(params["number_of_prior_convictions"])
      elsif params["prior_conviction_bounds"] == "fewer"
        scope = scope.number_of_prior_criminal_convictions_lte(params["number_of_prior_convictions"])
      end
    end

    if params["bail_set"]
      if params["bail_set"] == "Y"
        scope = scope.bail_or_remand_set_on_defendant
      elsif params["bail_set"] == "N"
        scope = scope.bail_or_remand_not_set_on_defendant
      end
    end

    if params["arraigned"]
      if params["arraigned"] == "Y"
        scope = scope.post_arraignment
      elsif params["arraigned"] == "no"
        scope = scope.pre_arraignment
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

    if params["sort"]
      if params["sort"] == "Next Court Date"
        scope = scope.order_by(next_court_date: :asc)
      elsif params["sort"] == "Next Court Part"
        scope = scope.order_by(next_courthouse: :asc, next_court_part: :asc)
      elsif params["sort"] == "Defendant Name"
        scope = scope.order_by(defendant_name: :asc)
      elsif params["sort"] == "Top Charge"
        scope = scope.order_by(top_charge_sort: :asc)
      elsif params["sort"] == "Prior Criminal Convictions"
        scope = scope.order_by(number_of_prior_criminal_convictions: :asc)
      end
    else
      scope = scope.order_by(next_court_date: :asc)
    end

  end
end
