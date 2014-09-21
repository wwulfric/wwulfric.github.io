#= require vendor/jquery
#= require vendor/jquery.fancybox

$ ->

  $('.post-image').fancybox()

  $('#get-comment').fancybox
        'href' : $(this).attr('href'),
        'titleShow' : false,
        'closeBtn' : false,

  return
