//= require jquery-1.10.2.min.js
//= require bootstrap.min.js

$(function(){
  $('.more-or-less').each(function(i, el) {
    // console.log(el);
    $(el).find("li a").click(function() {
    $(el).find("button").html($(this).text() + ' <span class="caret"></span>');
    $(el).find("input.more-or-less-type").val($(this).text());
    });
  });

  $(".formify").each(function (_, element) {
    var value = $(element).find("[data-selected='true']").first().addClass("active").data("value");
    $(element).append('<input class="formify-value" type="hidden" name="filter[' + $(this).data('name') + ']" value="' + value + '" >');
  });

  $(".formify .btn").click(function () {
    $(this).addClass("active");
    var val = $(this).data("value");
    var input = $(this).parent().find(".formify-value")
    // console.log(val)
    $(input).val(val)
  });

  $(".dropdown-input").each(function (_, element) {
    var val = $(element).val()
    var form = $(element).parent()
    form.find(".dropdown-opt").each(function (_, opt_element) {
      var opt_element = $(opt_element)
      if (opt_element.data("value") === val) {
        var dropdown_text = form.find(".dropdown-main-text")
        dropdown_text.text(opt_element.text())
      }
    })
  })

  $(".dropdown-opt").click(function () {
    var form = $(this).parents(".dropdown-form")
    form.find(".dropdown-input").val($(this).data("value"))
    form.find(".dropdown-main-text").text($(this).text())
  })

  $(".select-all").click(function(event) {
    $(event.target).parent().parent().find("input").prop("checked", true);
    event.preventDefault();
  });

  $(".clear-all").click(function(event) {
    $(event.target).parent().parent().find("input").prop("checked", false);
    event.preventDefault();
  });

  $(".collapse").on('hide', function(event){
    var collapsingEl = $(event.target);
    var indicator = collapsingEl.parent().find(".collapse-indicator");
    indicator.animateRotate(90, 400, undefined, function(){
      indicator.css("-webkit-transform", "");
      indicator.removeClass("open").addClass("closed");
    }, function(now) {
      if (now > 83)
        collapsingEl.addClass("closed");
    });
  });

  $(".collapse").on('show', function(event){
    var collapsingEl = $(event.target);
    var indicator = collapsingEl.parent().find(".collapse-indicator");
    indicator.animateRotate(-90, 400, undefined, function(){
      indicator.css("-webkit-transform", "");
      indicator.removeClass("closed").addClass("open");
    }, function(now) {
      if (now < -1)
        collapsingEl.removeClass("closed");
    });
  });

  $.fn.animateRotate = function(angle, duration, easing, complete, customStep) {
    var args = $.speed(duration, easing, complete);
    var step = args.step;
    return this.each(function(i, e) {
      args.step = function(now) {
        if (customStep !== undefined)
          customStep(now);
        $.style(e, 'transform', 'rotate(' + now + 'deg)');
          if (step) return step.apply(this, arguments);
        };

        $({deg: 0}).animate({deg: angle}, args);
    });
};
});
