spawn = require('child_process').spawn
Q = require 'q'
fs = require 'fs'

uuid = require 'uuid'

{exec} = require 'child_process'

module.exports = (pathDir,zipFile,cb)->

  Q.Promise (resolve, reject, notify) ->

  # exec
    
    if process.platform is "win32"
      commands = "#{atom.getConfigDirPath()}/packages/atom-chameleon/utils/zip.exe -r #{zipFile} ./"
    else
      commands = "zip -r #{zipFile} ./"

    options =
      cwd:"#{pathDir}"
      maxBuffer:1024*1024*10
    foreverossZip = exec commands, options, (error,stdout,stderr)=>
      if error isnt null
        reject(error)
      # zip_path = "#{pathDir}/#{decs}"
      resolve(zipFile)

  # spawn
    # args = ["-r",decs,source];
    # foreverossZip = spawn("zip", args,{cwd:"#{pathDir}"})
    #
    # foreverossZip.stdout.on('data',(data)->
    #   console.log "stdout:"+data
    # )
    #
    # foreverossZip.stderr.on('data',(data)->
    #   # errorcb && errorcb(data)
    #   console.log data
    # )
    #
    # foreverossZip.on 'close',(status)->
    #   zip_path = "#{pathDir}/#{decs}"
    #
    #   if status is 0
    #     resolve(zip_path)
    #   else
    #     reject(status)
