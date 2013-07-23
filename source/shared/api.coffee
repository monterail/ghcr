class API
  url: "http://ghcr-staging.herokuapp.com/api/v1"

  constructor: (@browser, @repo, @access_token) ->

  init: (repo) ->
    @browser.get "#{@url}/#{repo}", {}, @access_token

  commits: (repo, params) ->
    @browser.get "#{@url}/#{repo}/commits", params, @access_token

  commit: (repo, id, params = {}) ->
    @browser.get "#{@url}/#{repo}/commits/#{id}", params, @access_token

  connect: (repo) ->
    @browser.post "#{@url}/#{repo}/connect", {}, @access_token

  save: (repo, id, commit) ->
    @browser.put "#{@url}/#{repo}/commits/#{id}", commit, @access_token

  authorize: (state = "") ->
    @browser.save('state', state)
    @browser.redirect "#{@url}/authorize?redirect_uri=#{@browser.href()}&state=#{state}"
