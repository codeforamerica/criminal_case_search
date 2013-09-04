module ApplicationHelper
  def build_radio_field(name, value, label, options = {})
    build_field("radio", name, value, label, options)
  end

  def build_checkbox_field(name, value, label, options = {})
    build_field("checkbox", name, value, label, options)
  end

  # LOL
  def build_field(type, name, value, label, options = {})
    html = <<html
  <div class="field">
    <input type="#{type}"
           name="#{type == 'checkbox' ? 'filter[' + name + '][]' : 'filter[' + name + ']'}"
           id="#{name}-#{value}"
           value="#{value}"
html

    if params[:filter][name].present?
      if params[:filter][name].include?(value)
        html += " checked "
      end
    elsif !!options[:selected] == true
      html += " checked "
    else
      ""
    end

    html += ">" # Close the input tag.

    html += "<label for=\"#{name}-#{value}\">#{label}</label></div>"
    html
  end

  def triple_select(name)
<<html
<div class="triple-select">
<input type="radio" name="filter[#{name}]" value="#{name}-disable" id="#{name}-disable">
<label for="#{name}-disable"><span class="icon-ok">I</span></label>
<input type="radio" name="filter[#{name}]" value="#{name}-neutral" id="#{name}-neutral">
<label for="#{name}-neutral"><span class="icon-minus">N</span></label>
<input type="radio" name="filter[#{name}]" value="#{name}-enable" id="#{name}-enable">
<label for="#{name}-enable"><span class="icon-remove">R</span></label>
html
  end

  def double_select(name)
<<html
<div class="double-select">
<input type="radio" name="filter[#{name}]" value="#{name}-disable" id="#{name}-disable">
<label for="#{name}-disable"><span class="icon-ok">Yes</span></label>
<input type="radio" name="filter[#{name}]" value="#{name}-enable" id="#{name}-enable">
<label for="#{name}-enable"><span class="icon-minus">No</span></label>
<input type="radio" name="filter[#{name}]" value="#{name}-all" id="#{name}-all" checked>
<label for="#{name}-all"><span class="icon-minus">All</span></label>
html
  end

  # Takes in an incident and tries to build a view around the top charge.
  def format_top_charge(incident)
    return %Q(<span title="#{incident.charges.first[:description]}"><b>#{incident.charges.first[:agency_code]}</b></span>) unless incident.charges.blank?
  end

  def show_ror_recommendations(incident)
    incident.ror_report.try { |r| r.recommendations.map { |x| x.capitalize }.join(", ") }
  end
end
