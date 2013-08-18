module ApplicationHelper
  def build_radio_field(name, value, label)
<<html
  <div class="field">
    <input type="radio"
           name="filter[#{name}]"
           id="#{name}-#{value}"
           value="#{value}"
           #{params[:filter][name] == value ? "checked" : ""}>
    <label for="#{name}-#{value}">#{label}</label>
  </div>
html
  end
end
