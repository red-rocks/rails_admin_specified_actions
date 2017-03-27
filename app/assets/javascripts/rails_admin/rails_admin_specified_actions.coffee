$(document).on "ajax:complete", "#rails_admin_specified_actions_wrapper #rails_admin_specified_actions .form_block form", (e, xhr, opts)->
  form = $(e.currentTarget)
  result_block = form.closest(".form_block").siblings(".ajax_result_block")
  error_block = result_block.siblings(".ajax_error_block")
  json = $.parseJSON(xhr.responseText)
  result_block.stop().hide().html(json['result']).show(100)
  error_block.stop().hide()
  if json['error']
    console.log(json)
    error_block.find(".message").html(json['error']['message'])     if json['error']['message']
    error_block.find(".backtrace").html(json['error']['backtrace']) if json['error']['backtrace']
    error_block.show(100)


$(document).on "ajax:before", "#rails_admin_specified_actions_wrapper #rails_admin_specified_actions .form_block form", (e)->
  form = $(e.currentTarget)
  result_block = form.closest(".form_block").siblings(".ajax_result_block")
  error_block = result_block.siblings(".ajax_error_block")
  result_block.hide(200)
  error_block.hide(200)



$(document).on "click", ".content > .alert > .show_hide, #rails_admin_specified_actions_wrapper #rails_admin_specified_action .ajax_error_block .backtrace > .show_hide", (e)->
  e.preventDefault()
  $(e.currentTarget).parent().toggleClass('short')
  return false
