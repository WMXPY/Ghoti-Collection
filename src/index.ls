#!/usr/bin/env node
require! {
    fs,
    path,
    './config': config
    './config': { updateConfig }
    './log': { log, logHelp, logInfo, logAbout, logVersion, logCommand, logUnknown, logStatus }
    './argv': { argv, env, ghotiConfig, path_ghoti }
    './init': { init }
    './component': { component }
    './page': { page }
    './lambda': { lambda }
    './func': { func }
}

const ghoti = ghotiConfig
const ghotiCLIPath = (path.join path_ghoti, "..", "..")
argv!

const excute = ->
    var whenDone
    switch(env.mode)
        case 'about'
            (logAbout!)
        case 'empty'
            (logHelp true)
        case 'version'
            (logVersion!)
        case 'help'
            (logHelp!)
        case 'status'
            (logStatus ghoti)
        case 'info'
            (logInfo env.texture[0])
        case 'init'
            whenDone = (logCommand!)
            (init ghotiCLIPath, env.texture[0], env.texture[1], whenDone)
        case 'lambda'
            whenDone = (logCommand!)
            (lambda ghotiCLIPath, process.cwd!, env.texture[0], ghoti, whenDone)
            (whenDone!)
        case 'func'
            whenDone = (logCommand!)
            (func ghotiCLIPath, process.cwd!, env.texture[0], ghoti, whenDone)
            (whenDone!)
        case 'function'
            whenDone = (logCommand 'function', 'func')
            (func ghotiCLIPath, process.cwd!, env.texture[0], ghoti, whenDone)
            (whenDone!)
        case 'page'
            whenDone = (logCommand!)
            (page ghotiCLIPath, process.cwd!, env.texture[0], ghoti, whenDone)
            (whenDone!)
        case 'component'
            whenDone = (logCommand!)
            (component ghotiCLIPath, process.cwd!, env.texture[0], ghoti, whenDone)
            (whenDone!)
        default
            (logUnknown!)
    void

excute!
# log env
# init 'react', './a/'
# log config.initConfig 'react'