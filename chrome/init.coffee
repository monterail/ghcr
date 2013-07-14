chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  chunks = window.location.pathname.split("/")
  repo = "#{chunks[1]}/#{chunks[2]}"

  GHCR.init repo, ->
    if window.location.hash == "#ghcr-pending"
      GHCR.pending()
    else if window.location.hash == "#ghcr-rejected"
      GHCR.rejected()
    else
      switch chunks[3]
        when "commits" # Commit History page
          GHCR.commitsPage()
        when "commit" # Commit details page
          GHCR.commitPage(chunks[4])
