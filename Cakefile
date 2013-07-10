fs     = require 'fs'
{exec} = require 'child_process'

package_file =
  firefox:  "package.json"
  chrome:   "manifest.json"

task 'build:chrome', 'Build chrome extension folder from source', ->
  compile("chrome")
  zip("chrome")

task 'release:chrome', 'Build and zip chrome extension folder from source', ->
  compile("chrome")
  zip("chrome")

task 'build:firefox', 'Build firefox extension folder from source', ->
  compile("firefox")

compile = (browser) ->
  copy = ->
    exec "rm -rf #{build_path} #{build_path}.zip"
    exec "mkdir -p #{build_path}"
    exec "mkdir #{build_path}/lib #{build_path}/data"
    exec "cp -R shared/lib #{build_path}/data/"
    exec "cp shared/*.{css,sass,scss} #{build_path}/data/"
    exec "cp #{browser}/#{package_file[browser]} #{build_path}"

  process_ghcr = ->
    ghcr_path = "#{build_path}/data/ghcr.coffee"
    fs.writeFile ghcr_path, ghcrContents.join('\n\n'), 'utf8', (err) ->
      throw err if err
      exec "coffee --compile #{ghcr_path}", (err, stdout, stderr) ->
        throw err if err
        out = stdout + stderr
        console.log out if out.length
        fs.unlink ghcr_path, ->
          console.log 'Compiled GHCR'

  compile_singles = ->
    singles = ["#{browser}/main.coffee"]
    singles.forEach (file) ->
      extension = (->
        ext = file.split '.'
        ext[Math.max 0, ext.length - 1]
      )()
      command = switch extension
        when 'coffee' then "coffee --compile --output #{build_path}/lib #{file} "
        when 'scss', 'sass' then "sass --no-cache #{file} >> #{build_path}/data/ghcr.css && rm #{file}"
        else throw "Unknown extension: #{file}"
      exec command, (err, stdout, stderr) ->
        throw err if err
        out = stdout + stderr
        console.log out if out.length
        console.log "Compiled #{file}"

  build_path = "builds/#{browser}"
  copy()
  ghcrFiles     = ["#{browser}/api", "shared/ghcr", "#{browser}/init"]
  ghcrContents  = []
  for file, index in ghcrFiles then do (file, index) ->
    fs.readFile "#{file}.coffee", 'utf8', (err, fileContents) ->
      throw err if err
      ghcrContents[index] = fileContents
      process_ghcr() if ghcrContents.length == ghcrFiles.length
  compile_singles()

zip = (browser) ->
  build_path = "builds/#{browser}"
  exec "cd #{build_path}"
  exec "zip -r #{build_path} #{browser}", (err, stdout, stderr) ->
    throw err if err
    out = stdout + stderr
    console.log out if out.length
    console.log "Zip #{build_path}.zip prepared"
