// Generated by CoffeeScript 1.4.0
(function() {
  var API, GHCR;

  API = function(url, repo) {
    return {
      commits: function(ids, cb) {
        return $.post("" + url + "/commits", {
          repo: repo,
          ids: ids
        }, cb, 'json');
      },
      commit: function(id, cb) {
        return $.getJSON("" + url + "/commit", {
          repo: repo,
          id: id
        }, cb);
      },
      save: function(data, cb) {
        return $.post("" + url + "/save", $.extend({}, data, {
          repo: repo
        }), cb);
      },
      pending: function(user, cb) {
        return $.get("" + url + "/pending", {
          repo: repo,
          user: user
        }, cb, 'json');
      },
      pendingCount: function(user, cb) {
        return $.get("" + url + "/pending/count", {
          repo: repo,
          user: user
        }, cb, 'json');
      }
    };
  };

  GHCR = {
    init: function(repo) {
      this.repo = repo;
      this.api = API(this.getApiUrl(), repo);
      this.user = $.trim($("#user-links .name").text());
      this.initPendingTab();
      return this.initSettings();
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
        $("a#ghcr-pending-tab").remove();
        $ul = $("li a.tabnav-tab:contains('Commits')").parent().parent();
        $li = $("<li/>");
        $a = $("<a href='#ghcr-pending' id='ghcr-pending-tab' class='tabnav-tab'>Pending commits <span class='counter'>" + res.count + "</span></a>").click(function() {
          return _this.pending();
        });
        $li.append($a);
        return $ul.append($li);
      });
    },
    initSettings: function() {
      var $a, $li, $ul,
        _this = this;
      $ul = $('span.tabnav-right ul.tabnav-tabs');
      $li = $("<li/>");
      $a = $("<a href='' class='tabnav-tab'>Set apiUrl</a>").click(function(e) {
        e.preventDefault();
        return _this.setApiUrl();
      });
      $li.append($a);
      return $ul.prepend($li);
    },
    pending: function() {
      var _this = this;
      return this.api.pending(this.user, function(commits) {
        var $container, $ol, commit, diffUrl, treeUrl, _i, _len;
        $(".tabnav-tabs a").removeClass("selected");
        $("#ghcr-pending-tab").addClass("selected");
        $container = $("#js-repo-pjax-container");
        $container.html("<h3 class=\"commit-group-heading\">Pending commits</h3>");
        $ol = $("<ol class='commit-group'/>");
        for (_i = 0, _len = commits.length; _i < _len; _i++) {
          commit = commits[_i];
          diffUrl = "/" + _this.repo + "/commit/" + commit.id;
          treeUrl = "/" + _this.repo + "/tree/" + commit.id;
          $ol.append($("<li class=\"commit commit-group-item js-navigation-item js-details-container\">\n  <p class=\"commit-title  js-pjax-commit-title\">\n    <a href=\"" + diffUrl + "\" class=\"message\">" + commit.message + "</a>\n  </p>\n  <div class=\"commit-meta\">\n    <div class=\"commit-links\">\n      <span class=\"js-zeroclipboard zeroclipboard-button\" data-clipboard-text=\"" + commit.id + "\" data-copied-hint=\"copied!\" title=\"Copy SHA\">\n        <span class=\"octicon octicon-clippy\"></span>\n      </span>\n\n      <a href=\"" + diffUrl + "\" class=\"gobutton \">\n        <span class=\"sha\">" + (commit.id.substring(0, 10)) + "\n          <span class=\"octicon octicon-arrow-small-right\"></span>\n        </span>\n      </a>\n\n      <a href=\"" + treeUrl + "\" class=\"browse-button\" title=\"Browse the code at this point in the history\" rel=\"nofollow\">\n        Browse code <span class=\"octicon octicon-arrow-right\"></span>\n      </a>\n    </div>\n\n    <div class=\"authorship\">\n      <span class=\"author-name\"><a href=\"/" + commit.author.username + "\" rel=\"author\">" + commit.author.username + "</a></span>\n      authored <time class=\"js-relative-date\" datetime=\"" + commit.timestamp + "\" title=\"2013-03-17 16:56:15\">2 days before the day after tomorow</time>\n    </div>\n  </div>\n</li>"));
        }
        return $container.append($ol);
      });
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
    commitPage: function(id) {
      var render,
        _this = this;
      render = function(commit) {
        var $box, $btn, btnlbl, info, status;
        if (commit == null) {
          commit = {};
        }
        commit.status || (commit.status = "pending");
        commit.id || (commit.id = id);
        switch (commit.status) {
          case "accepted":
            status = "pending";
            btnlbl = "Make pending";
            console.log(commit.created_at);
            info = "Commit accepted by <a href='https://github.com/" + commit.reviewer + "'>" + commit.reviewer + "<a/> at " + commit.updated_at;
            break;
          default:
            status = "accepted";
            btnlbl = "Accept";
            info = "Code review pending";
        }
        $btn = $("<button class='minibutton'>" + btnlbl + "</button>").click(function() {
          commit.status = status;
          commit.reviewer = _this.user;
          return _this.api.save(commit, function(data) {
            render(data);
            return _this.initPendingTab();
          });
        });
        $("#ghcr-box").remove();
        $box = $("<div id='ghcr-box' class='ghcr-" + commit.status + "'><span>" + info + "</span> </div>");
        $box.append($btn);
        return $("#js-repo-pjax-container").prepend($box);
      };
      return this.api.commit(id, render);
    }
  };

  chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
    var chunks, repo;
    chunks = window.location.pathname.split("/");
    repo = "" + chunks[1] + "/" + chunks[2];
    GHCR.init(repo);
    if (window.location.hash === "#ghcr-pending") {
      return GHCR.pending();
    } else {
      switch (chunks[3]) {
        case "commits":
          return GHCR.commitsPage();
        case "commit":
          return GHCR.commitPage(chunks[4]);
      }
    }
  });

}).call(this);
