ProgressView = require './progress-view'
_ = require 'underscore'

# for debug properse only, it will add many ms to startup time.
# Q = require 'q'
# Q.longStackSupport = true

module.exports =

  activate: (state) ->
    atom.workspaceView.command "atom-butterfly:install", => @cmdInstall()
    atom.workspaceView.command "atom-butterfly:debug", => @cmdDebug()

    atom.workspaceView.command "atom-butterfly:create-project", => @cmdCreateProject()
    atom.workspaceView.command "atom-butterfly:run-on-server", => @cmdRunOnServer()

    atom.workspaceView.command "atom-butterfly:emulator", =>@cmdLaunchEmulator()

  deactivate: ->
    @runOnServerView?.destroy()
    @serverStatusView?.destroy()

    @debugServer?.stop()

  cmdDebug: ->
    BowerView = require './scaffold/bower-view'
    new BowerView().attach()

  cmdCreateProject: ->

    ProjectWizardView = require './scaffold/project-wizard-view'
    projectWizardView = new ProjectWizardView().attach()

    projectWizardView.on 'finish', (options) =>

      dialog = require('remote').require 'dialog'
      dialog.showOpenDialog
        title: 'Select Root Path'
        defaultPath: atom.project.path
        properties: ['openDirectory']
      , (destPath) =>

        return unless destPath

        #merge destPath to options
        _.extend(options, path: destPath[0])

        projectWizardView.destroy()

        pv = new ProgressView("Create Project...")
        pv.attach()

        {createProjectPromise} = require './scaffold'

        createProjectPromise(options)
        .progress (progress)->
          pv.setTitle(progress.message) if progress.message
          pv.setProgress(progress.progress) if progress.progress
        .then (projectPath)->
          atom.open {pathsToOpen: [projectPath]}
        .catch (error) ->
          console.trace error.stack
        .finally ->
          pv.destroy()

        # Scaffolder.createProject(options)
        # .on 'message', (message) ->
        #   pv.setTitle(message)
        # .on 'progress', (progress) ->
        #   pv.setProgress(progress)
        # .on 'finish', ->
        #   pv.destroy()
        #   atom.open {pathsToOpen: [destPath]}

  cmdInstall: ->

    pv = new ProgressView("Install Butterfly.js...")
    pv.attach()

    Scaffolder = require './scaffold'
    Scaffolder.installFrameworkPromise()
    .progress (progress)->
      pv.setTitle(progress.message) if progress.message
      pv.setProgress(progress.progress) if progress.progress
    .then ->
      pv.destroy()

    # Scaffolder.installFramework()
    # .on 'message', (message) ->
    #   pv.setTitle(message)
    # .on 'progress', (progress) ->
    #   pv.setProgress(progress)
    # .on 'finish', ->
    #   pv.destroy()

  cmdRunOnServer: ->

    @_setupDebugServer()

    RunOnServerView = require './run-on-server-view'
    @runOnServerView = new RunOnServerView()
    @runOnServerView.attach()
    @runOnServerView.on 'createServer', (event, rootPath, destPath, httpPort, pushState, api)=>
      @debugServer.start {
        rootPath: rootPath
        defaultPage: destPath
        httpPort: httpPort
        pushState: pushState
        api: api
      }

  _setupDebugServer: ->

    unless @serverStatusView and @debugServer

      ServerStatusView = require './server-status-view'
      @serverStatusView = new ServerStatusView()
      @serverStatusView.on 'stopServer', => @debugServer.stop()

      DebugServer = require './debug-server'
      @debugServer = new DebugServer()
      @debugServer.on 'start', => @serverStatusView.attach()
      @debugServer.on 'stop', => @serverStatusView.detach()

  cmdLaunchEmulator: ->

    unless @emulatorView?
      EmulatorView = require './emulator/emulator-view'
      @emulatorView = new EmulatorView()

    @emulatorView.toggle()
