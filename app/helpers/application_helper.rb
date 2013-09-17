module ApplicationHelper
  def build_radio_field(name, value, label, options = {})
    build_field("radio", name, value, label, options)
  end

  def build_checkbox_field(name, value, label, options = {})
    build_field("checkbox", name, value, label, options)
  end

  def build_disc(label, klass, title = label)
<<html
<div class="disc #{klass}" title="#{title}">
  <div class="disc-internal">
    #{label}
  </div>
</div>
html
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
      if params[:filter][name].to_a.include?(value)
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
    selected = params[:filter][name]
<<html
<div class="formify btn-group" data-toggle="buttons-radio" data-name="#{name}">
<button class="btn" type="button" data-value="A" #{'data-selected="true"' if selected == "A" || selected == nil}>All</label>
<button class="btn" type="button" data-value="Y" #{'data-selected="true"' if selected == "Y"}>Yes</label>
<button class="btn" type="button" data-value="N" #{'data-selected="true"' if selected == "N"}>No</label>
</div>
html
  end

  def true_if(param, values)
    values = [values].flatten
    if values.include?(param)
      "true"
    else
      "false"
    end
  end

  # Takes in an incident and tries to build a view around the top charge.
  def format_top_charge(incident)
    %Q(<span title="#{incident.top_charge["description"]}"><b>#{incident.top_charge["agency_code"]}</b></span>)
  end

  def show_ror_recommendations(incident)
    incident.ror_report.try { |r| r.recommendations.map { |x| x.capitalize }.join(", ") }
  end
end
