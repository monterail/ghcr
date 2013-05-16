// Generated by CoffeeScript 1.4.0
(function() {
  var RedisStore, Store, apiUrl, formatKey, getNamespace, render, user;

  apiUrl = 'http://127.0.0.1:9393/ghcr';

  getNamespace = function() {
    var array;
    array = $('h1 a.js-current-repository').attr('href').split('/');
    array.shift();
    return array.join(':');
  };

  formatKey = function(hash) {
    return "" + (getNamespace()) + ":" + hash;
  };

  RedisStore = {
    mget: function(ks, cb) {
      return $.post("" + apiUrl + "/mget", {
        keys: ks,
        namespace: getNamespace()
      }, cb, 'json');
    },
    get: function(k, cb) {
      return $.getJSON("" + apiUrl + "/get", {
        key: formatKey(k)
      }, cb);
    },
    set: function(k, user) {
      return $.post("" + apiUrl + "/set", {
        key: formatKey(k),
        user: user
      }, function(data) {
        return console.log('saved');
      });
    },
    del: function(k) {
      return $.ajax({
        url: "" + apiUrl + "/del",
        type: 'delete',
        data: {
          key: formatKey(k),
          "_method": "delete"
        },
        complete: function(data) {
          return console.log('deleted');
        }
      });
    }
  };

  Store = RedisStore;

  user = $.trim($("#user-links .name").text());

  render = function() {
    var e, id, ids;
    if ($(".breadcrumb").text().match(/Commit History/)) {
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
      return Store.mget(ids, function(results) {
        var $item, result, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = results.length; _i < _len; _i++) {
          result = results[_i];
          $item = $("li.commit .commit-links .js-zeroclipboard[data-clipboard-text=" + result.id + "]").parents("li");
          if (result.user) {
            _results.push($item.addClass("ghcr-done"));
          } else {
            _results.push($item.addClass("ghcr-pending"));
          }
        }
        return _results;
      });
    } else if ($(".full-commit").size() > 0) {
      id = $(".full-commit .sha.js-selectable-text").text();
      return Store.get(id, function(data) {
        var $btn, done, renderButton;
        done = data.user;
        $btn = function() {
          var lbl;
          lbl = done ? "Make pending" : "Accept";
          return $("<button class='minibutton'>" + lbl + "</button>").click(function() {
            if (done) {
              Store.del(id);
              done = null;
            } else {
              Store.set(id, user);
              done = user;
            }
            return renderButton();
          });
        };
        renderButton = function() {
          var $box, cls, str, _ref;
          $("#ghcr-box").remove();
          _ref = done ? ["ghcr-done", "Commit accepted by <a href='https://github.com/" + done + "'>" + done + "<a/>"] : ["ghcr-pending", "Code review pending"], cls = _ref[0], str = _ref[1];
          $box = $("<div id='ghcr-box' class='" + cls + "'><span>" + str + "</span> </div>");
          $box.append($btn());
          return $("#js-repo-pjax-container").prepend($box);
        };
        return renderButton();
      });
    }
  };

  chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
    console.log("trigger render " + (+new Date()));
    return render();
  });

}).call(this);
