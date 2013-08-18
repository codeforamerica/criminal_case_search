$(function(){
  $('.more-or-less').each(function(i, el) {
  console.log(el);
    $(el).find("li a").click(function() {
    $(el).find("button").html($(this).text() + ' <span class="caret"></span>');
    $(el).find("input.more-or-less-type").val($(this).text());
    });
  });

  $("#select-sex").buttonset();

  $('.slider').slider({
    range: true,
    min: 18,
    max: 100,
    values: [ 18, 65 ]
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
