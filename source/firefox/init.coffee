new class FirefoxGHCR extends GHCR
  constructor: ->
    @browser = new FirefoxBrowser
    super
