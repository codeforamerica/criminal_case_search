$(function(){
  $('.more-or-less').each(function(i, el) {
  console.log(el);
    $(el).find("li a").click(function() {
    $(el).find("button").html($(this).text() + ' <span class="caret"></span>');
    $(el).find("input.more-or-less-type").val($(this).text());
    });
  });

  $("#select-sex").buttonset();
  $(".triple-select, .double-select, .buttonset").buttonset();
  $(".spinner").spinner();

  $(".incident").click(function() {
    $(this).toggleClass("selected");
  });

  (function(element) {
    var update_label = function(event, ui) {
      element.find(".slider-display-min").text(ui.values[0]);
      element.find(".slider-data-min").val(ui.values[0]);
      element.find(".slider-display-max").text(ui.values[1]);
      element.find(".slider-data-max").val(ui.values[1]);
    }

    var slider_min = element.find(".slider-data-min").val();
    var slider_max = element.find(".slider-data-max").val();
    update_label(null, { values: [ slider_min, slider_max ] });

    element.find('.slider-control').slider({
      range: true,
      min: 16,
      max: 100,
      values: [ slider_min, slider_max ],
      slide: update_label
    });
  })($(".slider"));

  $(".select-all").click(function(event) {
    $(event.target).parent().parent().find("input").prop("checked", true);
    event.preventDefault();
  });

  $(".clear-all").click(function(event) {
    $(event.target).parent().parent().find("input").prop("checked", false);
    event.preventDefault();
  });
})
