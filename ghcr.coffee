# API URL
apiUrl = 'http://webhooker.mh2.monterail.eu/ghcr'

getNamespace = ->
  array = $('h1 a.js-current-repository').attr('href').split('/')
  array.shift()
  array.join(':')

formatKey = (hash) ->
  "#{getNamespace()}:#{hash}"

# deprecated
# LocalStore =
#   mget: (ks) -> [k, @get(k)] for k in ks
#   get: (k) -> localStorage.getItem(formatKey(k))
#   set: (k, v) -> localStorage.setItem(formatKey(k),v)
#   del: (k) -> localStorage.removeItem(formatKey(k))

RedisStore =
  mget: (ks, cb) ->
    $.post "#{apiUrl}/mget", {keys: ks, namespace: getNamespace()}, cb, 'json'
  get: (k, cb) ->
    $.getJSON "#{apiUrl}/get", {key: formatKey(k)}, cb
  set: (k, user) ->
    $.post "#{apiUrl}/set", {key: formatKey(k), user: user}, (data) ->
      console.log 'saved'
  del: (k) ->
    $.ajax url: "#{apiUrl}/del",type: 'delete', data: {key: formatKey(k), "_method":"delete"}, complete: (data) ->
      console.log 'deleted'

Store = RedisStore
user = $.trim($("#user-links .name").text())

render = () ->
  if $(".breadcrumb").text().match(/Commit History/) # Commit History page
    ids = ($(e).data("clipboard-text") for e in $("li.commit .commit-links .js-zeroclipboard"))
    Store.mget ids, (results) ->
      for result in results
        $item = $("li.commit .commit-links .js-zeroclipboard[data-clipboard-text=#{result.id}]").parents("li")
        if result.user
          $item.addClass("ghcr-done")
        else
          $item.addClass("ghcr-pending")

  else if $(".full-commit").size() > 0
    id = $(".full-commit .sha.js-selectable-text").text()
    Store.get id, (data) ->
      done = data.user
      $btn = () ->
        lbl = if done then "Make pending" else "Accept"
        $("<button class='minibutton'>#{lbl}</button>").click () ->
          if done
            Store.del(id)
            done = null
          else
            Store.set(id, user)
            done = user
          renderButton()

      renderButton = () ->
        $("#ghcr-box").remove()
        [cls, str] = if done
          ["ghcr-done", "Commit accepted by <a href='https://github.com/#{done}'>#{done}<a/>"]
        else
          ["ghcr-pending", "Code review pending"]
        $box = $("<div id='ghcr-box' class='#{cls}'><span>#{str}</span> </div>")
        $box.append($btn())
        $("#js-repo-pjax-container").prepend($box)

      renderButton()


chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  # console.log request, sender, sendResponse
  console.log "trigger render #{+new Date()}"
  render()
