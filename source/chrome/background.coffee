# stolen from: http://adamfeuer.com/notes/2013/01/26/chrome-extension-making-browser-action-icon-open-options-page/

openOrFocusOptionsPage = ->
  optionsUrl = chrome.extension.getURL("settings.html")
  chrome.tabs.query {}, (extensionTabs) ->
    found = false
    i = 0

    while i < extensionTabs.length
      if optionsUrl is extensionTabs[i].url
        found = true
        chrome.tabs.update extensionTabs[i].id,
          selected: true
      i++
    chrome.tabs.create(url: "settings.html") if found is false

chrome.extension.onConnect.addListener (port) ->
  tab = port.sender.tab

  # This will get called by the content script we execute in
  # the tab as a result of the user pressing the browser action.
  port.onMessage.addListener (info) ->
    max_length = 1024
    info.selection = info.selection.substring(0, max_length)  if info.selection.length > max_length
    openOrFocusOptionsPage()

# Called when the user clicks on the browser action icon.
chrome.browserAction.onClicked.addListener (tab) ->
  openOrFocusOptionsPage()
