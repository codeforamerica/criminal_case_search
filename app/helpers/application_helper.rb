module ApplicationHelper
  def build_radio_field(name, value, label)
    build_field("radio", name, value, label)
  end

  def build_checkbox_field(name, value, label)
    build_field("checkbox", name, value, label)
  end

  # LOL
  def build_field(type, name, value, label)
    html = <<html
  <div class="field">
    <input type="#{type}"
           name="#{type == 'checkbox' ? 'filter[' + name + '][]' : 'filter[' + name + ']'}"
           id="#{name}-#{value}"
           value="#{value}"
html

    if type == "checkbox"
      if params[:filter][name].present?
        html += params[:filter][name].include?(value) ? "checked" : ""
      end
    else
      html += params[:filter][name] == value ? "checked" : ""
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
html
  end
end
