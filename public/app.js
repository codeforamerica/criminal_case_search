$(function(){
  $('.more-or-less').each(function(i, el) {
  console.log(el);
    $(el).find("li a").click(function() {
    $(el).find("button").html($(this).text() + ' <span class="caret"></span>');
    $(el).find("input.more-or-less-type").val($(this).text());
    });
  });

  $("#select-sex").buttonset();

  $('.slider-control').slider({
    range: true,
    min: 18,
    max: 100,
    values: [ 18, 65 ],
    slide: function(event, ui) {
      var parent = $(this).parent();
      parent.find(".slider-display-low").text(ui.values[0]);
      parent.find(".slider-data-low").val(ui.values[0]);
      parent.find(".slider-display-high").text(ui.values[1]);
      parent.find(".slider-data-high").val(ui.values[1]);
    }
  });

  $(".select-all").click(function(event) {
    $(event.target).parent().parent().find("input").prop("checked", true);
    event.preventDefault();
  });

  $(".clear-all").click(function(event) {
    $(event.target).parent().parent().find("input").prop("checked", false);
    event.preventDefault();
  });
})
