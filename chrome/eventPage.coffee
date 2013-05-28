console.log 'init evetPage'

ghcrRender = (details) ->
  return false unless /^https?:\/\/(.*\.)?github\.com/.test(details.url)
  chrome.tabs.sendMessage details.tabId, {}, (response) ->
    console.log response, 'response'

chrome.webNavigation.onCompleted.addListener (details) ->
  console.log 'onCompleted'
  ghcrRender(details)

chrome.webNavigation.onHistoryStateUpdated.addListener (details) ->
  console.log 'onHistoryStateUpdated'
  ghcrRender(details)
