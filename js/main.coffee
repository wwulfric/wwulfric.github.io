---
---

$ ->

  # retina img to 50%
  $('img').each ->
    if /R-/.test $(this).attr('src')
      $(this).attr('width', '50%')
      return

  # modal default
  $.modal.defaults.showClose = false
  # # scroll to bottom, get comments
  # $(window).scroll ->
  #   if $(window).scrollTop() + $(window).height() > $(document).height() - 200
  #     if $('#disqus_thread').html().length == 0
  #       window.get_comment()
  #   return

  return
