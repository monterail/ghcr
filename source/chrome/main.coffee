ghcrRender = (details) ->
  return false unless /^https?:\/\/(.*\.)?github\.com/.test(details.url)
  chrome.tabs.sendMessage details.tabId, { action: 'render' }

chrome.webNavigation.onCompleted.addListener (details) ->
  console.log 'onCompleted'
  ghcrRender(details)

chrome.webNavigation.onHistoryStateUpdated.addListener (details) ->
  console.log 'onHistoryStateUpdated'
  ghcrRender(details)

# Chrome needs dummy event listener on startup for others to work
chrome.runtime.onStartup.addListener ->
  console.log('browser startup')
