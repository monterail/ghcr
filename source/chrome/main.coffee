ghcrRender = (details) ->
  return false unless /^https?:\/\/(.*\.)?github\.com/.test(details.url)
  chrome.tabs.sendMessage details.tabId, { action: 'render' }

chrome.webNavigation.onHistoryStateUpdated.addListener (details) ->
  console.log 'onHistoryStateUpdated'
  ghcrRender(details)
