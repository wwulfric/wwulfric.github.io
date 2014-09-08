---
---

$ ->

  # retina img to 50%
  $('img').each ->
    if /R-/.test $(this).attr('src')
      $(this).attr('width', '50%')
      return


  return

