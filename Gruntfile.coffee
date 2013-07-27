require "shelljs/global"

# like set -e
config.fatal = true

module.exports = (grunt) ->
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-sass')
  grunt.loadNpmTasks('grunt-concat-sourcemap')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-multiresize')

  grunt.config.init
    pkg: grunt.file.readJSON "package.json"
    coffee:
      options: { join: true, sourceMap: true, bare: true }
      default: files:
        # shared
        "build/shared/ghcr.js": [
          "build/shared/app/browser.coffee"
          "build/shared/app/api.coffee"
          "build/shared/app/repository.coffee"
          "build/shared/app/template.coffee"
          "build/shared/app/user.coffee"
          "build/shared/ghcr.coffee"
        ]

        # Firefox
        "build/firefox/request.js":        ["build/firefox/request.coffee"]
        "build/firefox/storage.js":        ["build/firefox/storage.coffee"]
        "build/firefox/emit_callback.js":  ["build/firefox/emit_callback.coffee"]
        "build/firefox/lib/main.js":       ["build/firefox/main.coffee"]

        # Chrome
        "build/chrome/request.js":  ["build/chrome/request.coffee"]
        "build/chrome/storage.js":  ["build/chrome/storage.coffee"]
    sass:
      options: { lineNumbers: true }
      default: files:
        "build/shared/ghcr.css": ["build/shared/ghcr.sass"]
    concat_sourcemap:
      options: { sourcesContent: true, sourceRoot: 'foobar' }
      default: files:
        "build/chrome/ghcr.js": [
          "build/shared/vendor/*.js"
          "build/chrome/request.js"
          "build/chrome/storage.js"
          "build/shared/ghcr.js"
        ]
        "build/firefox/data/ghcr.js": [
          "build/shared/vendor/*.js"
          "build/firefox/emit_callback.js"
          "build/firefox/storage.js"
          "build/firefox/request.js"
          "build/shared/ghcr.js"
        ]
        "build/chrome/ghcr.css": ["build/shared/*.css"]
        "build/firefox/data/ghcr.css": ["build/shared/*.css"]
    uglify:
      options: { compress: true },
      default: files:
        "build/chrome/ghcr.js": "build/chrome/ghcr.js"
        "build/firefox/lib/main.js": "build/firefox/lib/main.js"
    watch:
      options: { atBegin: true }
      default:
        files: ['source/**']
        tasks: ['build', 'firefox:xpi', 'firefox:reload']
    multiresize:
      default:
        src: 'build/shared/icon256.png'
        dest: [
          'build/firefox/icon.png',
          'build/chrome/icon128.png',
          'build/chrome/icon48.png',
          'build/chrome/icon16.png',
        ]
        destSizes: ['128x128', '128x128', '48x48', '16x16']

  grunt.registerTask "build", "Build extension", ->
    rm "-rf", "build"
    cp "-r", "source/*", "build"
    grunt.task.run "coffee"
    grunt.task.run "sass"
    grunt.task.run "concat_sourcemap"
    grunt.task.run "multiresize"

  grunt.registerTask "release", "Release extension", ->
    grunt.task.run "build"
    grunt.task.run "uglify"
    grunt.task.run "zip"

  grunt.registerTask "zip", "Zip extension", ->
    exec "find build -name '*.coffee' | xargs rm"
    exec "find build -name '*.sass' | xargs rm"
    exec "find build -name '*.map' | xargs rm"
    exec "zip -r chrome.zip build/chrome"
    grunt.task.run "firefox:xpi"

  grunt.registerTask "firefox:xpi", "Pack Firefox plugin to xpi file", ->
    exec "dev/addon-sdk/bin/cfx --pkgdir=build/firefox xpi"

  grunt.registerTask "firefox:reload", "Send xpi file to Extension Auto Installer", ->
    exec "wget --post-file=ghcr.xpi http://localhost:8888"

  grunt.registerTask "default", ->
    grunt.log.writeln("grunt build")
    grunt.log.writeln("grunt release")
    grunt.log.writeln("grunt watch")
