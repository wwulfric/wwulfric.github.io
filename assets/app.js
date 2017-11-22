(function() {
  // 默认 comments 隐藏，get comment 按钮可以 toggle 状态
  var get_comment = document.getElementById('get-comment');
  get_comment.addEventListener('click', function() {
    // 通过添加和删除 comments-hide 类名实现
    var comments = document.getElementById('comments');
    var classList = comments.classList;
    var className = comments.className;
    var hiddenClassName = 'comments-hide';
    if (className.indexOf(hiddenClassName) < 0) {
      classList.add(hiddenClassName);
    } else {
      classList.remove(hiddenClassName);
    }
  });

  // footnote 鼠标经过的时候显示详情
  var footnotes = document.getElementsByClassName('footnote');
  // 取 footnote 上的 href，然后拿到对应的 innerText
  for (var i = 0; i < footnotes.length; i++) {
    var footnote = footnotes[i];
    var id = footnote.getAttribute('href').slice(1);
    var content = document.getElementById(id).querySelector('p').innerText;
    footnote.setAttribute('title', content);
  }
}).call(this);
