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
  grunt.loadNpmTasks('grunt-slim')
  grunt.loadNpmTasks('grunt-contrib-copy')

  grunt.config.init
    pkg: grunt.file.readJSON "package.json"
    coffee:
      options: { join: true, sourceMap: true, bare: true }
      default: files:
        # shared
        "build/shared/ghcr.js": [
          "build/shared/app/page.coffee"
          "build/shared/app/api.coffee"
          "build/shared/app/repository.coffee"
          "build/shared/app/template.coffee"
          "build/shared/app/user.coffee"
          "build/shared/ghcr.coffee"
        ]

        # Chrome
        "build/chrome/request.js":    ["build/chrome/request.coffee"]
        "build/chrome/storage.js":    ["build/chrome/storage.coffee"]
        "build/chrome/background.js": ["build/chrome/background.coffee"]
        "build/chrome/settings.js":   ["build/shared/settings.coffee"]
    sass:
      options: { lineNumbers: true }
      default: files:
        "build/shared/ghcr.css": ["build/shared/ghcr.sass"]
    slim: default: files:
        "build/chrome/settings.html": "source/shared/settings.slim"
    copy: default: files:
        "build/chrome/bootstrap.min.css": "source/shared/vendor/bootstrap.min.css"
        "build/chrome/ng-table.css": "source/shared/vendor/ng-table.css"
    concat_sourcemap:
      options: { sourcesContent: true, sourceRoot: 'foobar' }
      default: files:
        "build/chrome/ghcr.js": [
          "build/shared/vendor/*.js"
          "build/chrome/request.js"
          "build/chrome/storage.js"
          "build/shared/ghcr.js"
        ]
        "build/chrome/ghcr.css": ["build/shared/*.css"]
    uglify:
      options: { compress: true },
      default: files:
        "build/chrome/ghcr.js": "build/chrome/ghcr.js"
    watch:
      options: { atBegin: true }
      default:
        files: ['source/**']
        tasks: ['build']
    multiresize:
      default:
        src: 'build/shared/icon256.png'
        dest: [
          'build/chrome/icon128.png',
          'build/chrome/icon48.png',
          'build/chrome/icon38.png',
          'build/chrome/icon19.png',
          'build/chrome/icon16.png',
        ]
        destSizes: ['128x128', '128x128', '48x48', '38x38', '19x19', '16x16']

  grunt.registerTask "build", "Build extension", ->
    rm "-rf", "build"
    cp "-r", "source/*", "build"
    grunt.task.run "coffee"
    grunt.task.run "sass"
    grunt.task.run "slim"
    grunt.task.run "copy"
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

  grunt.registerTask "default", ->
    grunt.log.writeln("grunt build")
    grunt.log.writeln("grunt release")
    grunt.log.writeln("grunt watch")
