console.log 'init evetPage'

chrome.webNavigation.onCompleted.addListener (details) ->
  console.log 'onCompleted'
  chrome.tabs.sendMessage details.tabId, {}, (response) ->
    console.log response, 'response'

chrome.webNavigation.onHistoryStateUpdated.addListener (details) ->
  console.log 'onHistoryStateUpdated'
  chrome.tabs.sendMessage details.tabId, {}, (response) ->
    console.log response, 'response'
