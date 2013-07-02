// Generated by CoffeeScript 1.4.0
(function() {
  var API, GHCR, XHR, init, legacySend;

  API = function(url, repo) {
    return {
      sendRequest: function(type, url, data, cb) {
        var callMe;
        callMe = Math.random().toString(36).substring(7);
        self.port.on(callMe, cb);
        return self.port.emit("request:" + type, url, decodeURIComponent($.param(data)), callMe);
      },
      commits: function(ids, cb) {
        return this.sendRequest("post", "" + url + "/commits", {
          repo: repo,
          ids: ids
        }, cb);
      },
      commit: function(id, cb) {
        return this.sendRequest("get", "" + url + "/commit", {
          repo: repo,
          id: id
        }, cb);
      },
      save: function(data, cb) {
        return this.sendRequest("post", "" + url + "/save", $.extend({}, data, {
          repo: repo
        }), cb);
      },
      pending: function(user, cb) {
        return this.sendRequest("get", "" + url + "/pending", {
          repo: repo,
          user: user
        }, cb);
      },
      pendingCount: function(user, cb) {
        return this.sendRequest("get", "" + url + "/pending/count", {
          repo: repo,
          user: user
        }, cb);
      },
      rejected: function(user, cb) {
        return this.sendRequest("get", "" + url + "/rejected", {
          repo: repo,
          user: user
        }, cb);
      },
      rejectedCount: function(user, cb) {
        return this.sendRequest("get", "" + url + "/rejected/count", {
          repo: repo,
          user: user
        }, cb);
      },
      notify: function(reviewer, action, cb) {
        return this.sendRequest("post", "" + url + "/notify", {
          repo: repo,
          action: action,
          reviewer: reviewer
        }, cb);
      }
    };
  };

  GHCR = {
    init: function(repo) {
      this.repo = repo;
      this.api = API(this.getApiUrl(), repo);
      this.user = $.trim($("#user-links .name").text());
      this.initPendingTab();
      this.initRejectedTab();
      this.initSettings();
      return this.initNotify();
    },
    getApiUrl: function() {
      var apiUrl;
      apiUrl = localStorage.getItem('ghcr:apiUrl');
      if ($.trim(apiUrl) === "") {
        return 'http://localhost:9393/ghcr';
      } else {
        return apiUrl;
      }
    },
    setApiUrl: function() {
      var newApiUrl;
      newApiUrl = prompt("Set ghcr api url:", this.getApiUrl());
      if ($.trim(newApiUrl) === "") {
        return this.getApiUrl();
      } else {
        localStorage.setItem('ghcr:apiUrl', newApiUrl);
        window.location.reload();
        return newApiUrl;
      }
    },
    initPendingTab: function() {
      var _this = this;
      return this.api.pendingCount(this.user, function(res) {
        var $a, $li, $ul;
        $("li#ghcr-pending-tab").remove();
        $ul = $("div.repository-with-sidebar div.overall-summary ul.numbers-summary");
        if ($ul.find("li.commits").length && (res.count != null)) {
          $li = $("<li id='ghcr-pending-tab' />");
          $a = $("<a href='#ghcr-pending'><span class='num'>" + res.count + "</span> Pending</a>").click(function() {
            return _this.pending();
          });
          $li.append($a);
          $ul.append($li);
          if (res.count === 0) {
            return $('#ghcr-box button.next').remove();
          }
        }
      });
    },
    initRejectedTab: function() {
      var _this = this;
      return this.api.rejectedCount(this.user, function(res) {
        var $a, $li, $ul;
        $("li#ghcr-rejected-tab").remove();
        $ul = $("div.repository-with-sidebar div.overall-summary ul.numbers-summary");
        if ($ul.find("li.commits").length && (res.count != null)) {
          $li = $("<li id='ghcr-rejected-tab' />");
          $a = $("<a href='#ghcr-rejected'><span class='num'>" + res.count + "</span> Rejected</a>").click(function() {
            return _this.rejected();
          });
          $li.append($a);
          return $ul.append($li);
        }
      });
    },
    initSettings: function() {
      var $a, $li, $ul,
        _this = this;
      $("li#ghcr-settings").remove();
      $ul = $('.repo-nav-contents .repo-menu:last');
      $li = $("<li class='tooltipped leftwards' id='ghcr-settings' original-title='Ghcr api url' />");
      $a = $("<a href='' class=''><span class='octicon'>G</span> <span class='full-word'>Ghcr api url</span></a>").click(function(e) {
        e.preventDefault();
        return _this.setApiUrl();
      });
      $li.append($a);
      return $ul.append($li);
    },
    initNotify: function() {
      var $li, $ul,
        _this = this;
      $("li#ghcr-notify").remove();
      $ul = $('ul.pagehead-actions');
      $li = $("<li id='ghcr-notify' />");
      return this.api.notify(this.user, 'status', function(data) {
        var $a, action, btnlbl, enabled;
        enabled = data['enabled'];
        btnlbl = function(e) {
          if (e) {
            return "Unnotify";
          } else {
            return "Notify";
          }
        };
        action = function(e) {
          if (e) {
            return "disable";
          } else {
            return "enable";
          }
        };
        $a = $("<a href='' class='button minibutton'>" + (btnlbl(enabled)) + "</a>").click(function(e) {
          e.preventDefault();
          _this.api.notify(_this.user, action(enabled), null);
          enabled = !enabled;
          return $(e.target).text(btnlbl(enabled));
        });
        $li.append($a);
        return $ul.prepend($li);
      });
    },
    pending: function() {
      var _this = this;
      return this.api.pending(this.user, function(commits) {
        var $container, $ol;
        $(".tabnav-tabs a").removeClass("selected");
        $("#ghcr-pending-tab a").addClass("selected");
        $container = $("#js-repo-pjax-container");
        $container.html("<h3 class=\"commit-group-heading\">Pending commits</h3>");
        $ol = $("<ol class='commit-group'/>");
        _this.renderCommits($ol, commits);
        return $container.append($ol);
      });
    },
    rejected: function() {
      var _this = this;
      return this.api.rejected(this.user, function(commits) {
        var $container, $ol;
        $(".tabnav-tabs a").removeClass("selected");
        $("#ghcr-rejected-tab a").addClass("selected");
        $container = $("#js-repo-pjax-container");
        $container.html("<h3 class=\"commit-group-heading\">Rejected commits</h3>");
        $ol = $("<ol class='commit-group'/>");
        _this.renderCommits($ol, commits);
        return $container.append($ol);
      });
    },
    renderCommits: function($ol, commits) {
      var authorNameHtml, commit, diffUrl, treeUrl, _i, _len;
      for (_i = 0, _len = commits.length; _i < _len; _i++) {
        commit = commits[_i];
        diffUrl = "/" + this.repo + "/commit/" + commit.id;
        treeUrl = "/" + this.repo + "/tree/" + commit.id;
        authorNameHtml = commit.author.username ? "<a href=\"/" + commit.author.username + "\" rel=\"author\">" + commit.author.username + "</a>" : "<span rel=\"author\">" + commit.author.name + "</span>";
        $ol.append($("<li class=\"commit commit-group-item js-navigation-item js-details-container\">\n  <p class=\"commit-title  js-pjax-commit-title\">\n    <a href=\"" + diffUrl + "\" class=\"message\">" + commit.message + "</a>\n  </p>\n  <div class=\"commit-meta\">\n    <div class=\"commit-links\">\n      <span class=\"js-zeroclipboard zeroclipboard-button\" data-clipboard-text=\"" + commit.id + "\" data-copied-hint=\"copied!\" title=\"Copy SHA\">\n        <span class=\"octicon octicon-clippy\"></span>\n      </span>\n\n      <a href=\"" + diffUrl + "\" class=\"gobutton \">\n        <span class=\"sha\">" + (commit.id.substring(0, 10)) + "\n          <span class=\"octicon octicon-arrow-small-right\"></span>\n        </span>\n      </a>\n\n      <a href=\"" + treeUrl + "\" class=\"browse-button\" title=\"Browse the code at this point in the history\" rel=\"nofollow\">\n        Browse code <span class=\"octicon octicon-arrow-right\"></span>\n      </a>\n    </div>\n\n    <div class=\"authorship\">\n      <span class=\"author-name\">" + authorNameHtml + "</span>\n      authored <time class=\"js-relative-date\" datetime=\"" + commit.timestamp + "\" title=\"" + commit.timestamp + "\"></time>\n    </div>\n  </div>\n</li>"));
      }
      return $ol.find('time').timeago();
    },
    commitsPage: function() {
      var e, ids;
      ids = (function() {
        var _i, _len, _ref, _results;
        _ref = $("li.commit .commit-links .js-zeroclipboard");
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          e = _ref[_i];
          _results.push($(e).data("clipboard-text"));
        }
        return _results;
      })();
      return this.api.commits(ids, function(commits) {
        var $item, commit, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = commits.length; _i < _len; _i++) {
          commit = commits[_i];
          $item = $("li.commit .commit-links .js-zeroclipboard[data-clipboard-text=" + commit.id + "]").parents("li");
          commit.status || (commit.status = "pending");
          _results.push($item.addClass("ghcr-" + commit.status));
        }
        return _results;
      });
    },
    generateBtn: function(commit, btn) {
      var $btn,
        _this = this;
      $btn = $("<button class='minibutton " + btn.status + "'>" + btn.label + "</button>").click(function() {
        if (btn.status === 'next') {
          return _this.api.pending(_this.user, function(commits) {
            var commitSize, currentId, index, nextCommit, _i, _ref;
            currentId = window.location.pathname.split('/').reverse()[0];
            nextCommit = commits[0];
            commitSize = commits.length;
            for (index = _i = 0, _ref = commitSize - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; index = 0 <= _ref ? ++_i : --_i) {
              if (commits[index].id === currentId) {
                if (index + 1 < commitSize) {
                  nextCommit = commits[index + 1];
                }
                break;
              }
            }
            return window.location = "/" + _this.repo + "/commit/" + nextCommit.id;
          });
        } else {
          commit.status = btn.status;
          commit.reviewer = _this.user;
          return _this.api.save(commit, function(data) {
            _this.initPendingTab();
            _this.initRejectedTab();
            return _this.renderMenu(data);
          });
        }
      });
      return $btn;
    },
    renderMenu: function(commit) {
      var $box, acceptBtn, btn, info, nextPendingBtn, rejectBtn, setStickyHeader, stickyHeader;
      if (commit == null) {
        commit = {};
      }
      commit.author = {
        name: $.trim($(".commit-meta .author-name > span").text()),
        username: $.trim($(".commit-meta .author-name > a").text())
      };
      commit.message = $.trim($(".commit > .commit-title").text());
      $("#ghcr-box").remove();
      rejectBtn = {
        label: 'Reject',
        status: 'rejected'
      };
      acceptBtn = {
        label: 'Accept',
        status: 'accepted'
      };
      nextPendingBtn = {
        label: 'Next Pending',
        status: 'next'
      };
      switch (commit.status) {
        case "accepted":
          btn = rejectBtn;
          info = "Commit accepted by <a href='https://github.com/" + commit.reviewer + "'>" + commit.reviewer + "<a/> at " + (strftime('%R, %d %b %Y', new Date(commit.updated_at)));
          break;
        case "rejected":
          btn = acceptBtn;
          info = "Commit rejected by <a href='https://github.com/" + commit.reviewer + "'>" + commit.reviewer + "<a/> at " + (strftime('%R, %d %b %Y', new Date(commit.updated_at)));
          break;
        default:
          info = "Code review pending";
      }
      $box = $("<div id='ghcr-box' class='ghcr-" + commit.status + "'><span>" + info + "</span> </div>");
      if (parseInt($('#ghcr-pending-tab .counter').text(), 10) > 0) {
        $box.append(GHCR.generateBtn(commit, nextPendingBtn));
      }
      if ((commit.author.username || commit.author.name) !== this.user) {
        if (commit.status === 'pending') {
          $box.append(GHCR.generateBtn(commit, acceptBtn));
          $box.append(GHCR.generateBtn(commit, rejectBtn));
        } else {
          $box.append(GHCR.generateBtn(commit, btn));
        }
      }
      $("#js-repo-pjax-container").prepend($box);
      stickyHeader = {
        top: $box.offset().top,
        width: $box.width()
      };
      setStickyHeader = function() {
        if ($(window).scrollTop() > stickyHeader.top) {
          return $("#ghcr-box").css({
            position: "fixed",
            top: "0px",
            width: stickyHeader.width
          });
        } else {
          return $("#ghcr-box").css({
            position: "static",
            top: "0px",
            width: stickyHeader.width
          });
        }
      };
      setStickyHeader();
      return $(window).scroll(function() {
        return setStickyHeader();
      });
    },
    commitPage: function(id) {
      var _this = this;
      return this.api.commit(id, function(commit) {
        commit.id || (commit.id = id);
        commit.status || (commit.status = "pending");
        return _this.renderMenu(commit);
      });
    }
  };

  init = function() {
    var chunks, repo;
    chunks = window.location.pathname.split("/");
    repo = "" + chunks[1] + "/" + chunks[2];
    GHCR.init(repo);
    if (window.location.hash === "#ghcr-pending") {
      return GHCR.pending();
    } else if (window.location.hash === "#ghcr-rejected") {
      return GHCR.rejected();
    } else {
      switch (chunks[3]) {
        case "commits":
          return GHCR.commitsPage();
        case "commit":
          return GHCR.commitPage(chunks[4]);
      }
    }
  };

  self.port.on("init", init);

  XHR = unsafeWindow.XMLHttpRequest;

  legacySend = XMLHttpRequest.prototype.send;

  XHR.prototype.send = function() {
    var legacyORSC;
    legacyORSC = this.onreadystatechange;
    this.onreadystatechange = function() {
      if (this.readyState === 4 && (this.getResponseHeader("X-PJAX-VERSION") != null)) {
        setTimeout(init, 100);
      }
      return legacyORSC.apply(this, arguments);
    };
    return legacySend.apply(this, arguments);
  };

}).call(this);
