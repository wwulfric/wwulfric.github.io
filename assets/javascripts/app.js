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

    // Initialize Table of Contents
    initTOC();
  }

  function initTOC() {
    var tocNav = document.getElementById('toc-nav');
    var tocSidebar = document.getElementById('toc-sidebar');
    var tocToggle = document.getElementById('toc-toggle');
    var tocClose = document.getElementById('toc-close');

    if (!tocNav || !tocSidebar) return;

    // Get all headings from the post content
    var postContent = document.querySelector('.post-content');
    if (!postContent) return;

    var headings = postContent.querySelectorAll('h2, h3, h4');
    if (headings.length === 0) {
      // Hide TOC if no headings found
      tocSidebar.style.display = 'none';
      if (tocToggle) tocToggle.style.display = 'none';
      return;
    }

    // Generate TOC
    var tocHTML = '';
    headings.forEach(function(heading, index) {
      // Add ID to heading if it doesn't have one
      if (!heading.id) {
        heading.id = 'heading-' + index;
      }

      var level = heading.tagName.toLowerCase();
      var text = heading.textContent;
      var link = '#' + heading.id;

      tocHTML += '<a href="' + link + '" class="toc-' + level + '" data-target="' + heading.id + '">' +
                 text + '</a>';
    });

    tocNav.innerHTML = tocHTML;

    // Smooth scroll and active state
    var tocLinks = tocNav.querySelectorAll('a');
    tocLinks.forEach(function(link) {
      link.addEventListener('click', function(e) {
        e.preventDefault();
        var targetId = this.getAttribute('data-target');
        var target = document.getElementById(targetId);

        if (target) {
          target.scrollIntoView({ behavior: 'smooth', block: 'start' });

          // Close mobile TOC after clicking
          if (window.innerWidth <= 1200) {
            tocSidebar.classList.remove('toc-open');
          }
        }
      });
    });

    // Highlight active section on scroll
    var observerOptions = {
      rootMargin: '-100px 0px -66%',
      threshold: 0
    };

    var observer = new IntersectionObserver(function(entries) {
      entries.forEach(function(entry) {
        var id = entry.target.id;
        var tocLink = tocNav.querySelector('a[data-target="' + id + '"]');

        if (entry.isIntersecting && tocLink) {
          // Remove active class from all links
          tocLinks.forEach(function(link) {
            link.classList.remove('active');
          });
          // Add active class to current link
          tocLink.classList.add('active');
        }
      });
    }, observerOptions);

    // Observe all headings
    headings.forEach(function(heading) {
      observer.observe(heading);
    });

    // Mobile toggle functionality
    if (tocToggle) {
      tocToggle.addEventListener('click', function() {
        tocSidebar.classList.add('toc-open');
      });
    }

    if (tocClose) {
      tocClose.addEventListener('click', function() {
        tocSidebar.classList.remove('toc-open');
      });
    }

    // Close TOC when clicking outside on mobile
    document.addEventListener('click', function(e) {
      if (window.innerWidth <= 1200 &&
          tocSidebar.classList.contains('toc-open') &&
          !tocSidebar.contains(e.target) &&
          !tocToggle.contains(e.target)) {
        tocSidebar.classList.remove('toc-open');
      }
    });
  }
})();
