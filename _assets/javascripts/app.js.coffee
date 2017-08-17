#= require vendor/jquery

$ ->
  $('#get-comment').click ->
    $('#comments').toggle()

  $('.footnote').each (i, e) ->
    id = $(e).attr('href').replace(':','\\\:')
    content = $(id).find('p').text()
    $(e).attr('title', content)
  return
