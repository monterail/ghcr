new class ChromeGHCR extends GHCR
  constructor: ->
    @browser = new ChromeBrowser
    super
