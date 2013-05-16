LocalStore =
  mget: (ks) -> [k, @get(k)] for k in ks
  get: (k) -> localStorage.getItem(@key(k))
  set: (k, v) -> localStorage.setItem(@key(k),v)
  del: (k) -> localStorage.removeItem(@key(k))
  key: (k) -> "ghcr:#{k}"

RedisStore =
  mget: (ks) -> TODO
  get: (k) -> TODO
  set: (k, v) -> TODO
  del: (k) -> TODO

Store = LocalStore
user = $.trim($("#user-links .name").text())

if $(".breadcrumb").text().match(/Commit History/) # Commit History page
  ids = ($(e).data("clipboard-text") for e in $("li.commit .commit-links .js-zeroclipboard"))

  for [id,done] in Store.mget(ids)
    $item = $("li.commit .commit-links .js-zeroclipboard[data-clipboard-text=#{id}]").parents("li")

    if done
      $item.addClass("ghcr-done")
    else
      $item.addClass("ghcr-pending")
else if $(".full-commit").size() > 0
  id = $(".sha.js-selectable-text").text()
  done = Store.get(id)

  $btn = () ->
    lbl = if done then "Make pending" else "Accept"
    $("<button class='minibutton'>#{lbl}</button>").click () ->
      if done
        Store.del(id)
        done = null
      else
        Store.set(id, user)
        done = user
      render()

  render = () ->
    $("#ghcr-box").remove()
    [cls, str] = if done
      ["ghcr-done", "Commit accepted by <a href='https://github.com/#{done}'>#{done}<a/>"]
    else
      ["ghcr-pending", "Code review pending"]
    $box = $("<div id='ghcr-box' class='#{cls}'><span>#{str}</span> </div>")
    $box.append($btn())
    $("#js-repo-pjax-container").prepend($box)


chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  # console.log request, sender, sendResponse
  console.log 'trigger render'
  render()
