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
end
