(function() {
  'use strict';

  // Wait for DOM to be ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  function init() {
    // 默认 comments 隐藏，get comment 按钮可以 toggle 状态
    var get_comment = document.getElementById('get-comment');
    if (get_comment) {
      get_comment.addEventListener('click', function() {
        // 通过添加和删除 comments-hide 类名实现
        var comments = document.getElementById('comments');
        if (comments) {
          comments.classList.toggle('comments-hide');
        }
      });
    }

    // footnote 鼠标经过的时候显示详情
    var footnotes = document.getElementsByClassName('footnote');
    // 取 footnote 上的 href，然后拿到对应的 innerText
    for (var i = 0; i < footnotes.length; i++) {
      var footnote = footnotes[i];
      var id = footnote.getAttribute('href').slice(1);
      var element = document.getElementById(id);
      if (element) {
        var paragraph = element.querySelector('p');
        if (paragraph) {
          footnote.setAttribute('title', paragraph.innerText);
        }
      }
    }
  }
})();
