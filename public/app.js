$(function(){
  $('.more-or-less').each(function(i, el) {
  console.log(el);
    $(el).find("li a").click(function() {
    $(el).find("button").html($(this).text() + ' <span class="caret"></span>');
    $(el).find("input.more-or-less-type").val($(this).text());
    });
  });

  $(".formify").each(function (_, element) {
    var value = $(element).find("[data-selected='true']").first().addClass("active").data("value");
    $(element).append('<input class="formify-value" type="hidden" name="' + $(this).data('name') + '" value="' + value + '" >');
  });

  $(".formify .btn").click(function () {
    $(this).addClass("active");
    var val = $(this).data("value");
    var input = $(this).parent().find(".formify-value")
    console.log(val)
    $(input).val(val)
  });

  $(".incident").click(function() {
    $(this).toggleClass("selected");
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
