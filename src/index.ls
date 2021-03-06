require! {
    fs
    path
    './func/config': config
    './func/config': { updateConfig, cliPath }
    './log/log': { 
        log
        logHelp
        logHelpMore
        logInfo
        logPostNPMInstall
        logAbout
        logUnderline
        logVersion
        logCommand
        logSymbol
        logUnknown
        logStatus
        logWhatIs
        logUpdate
        logList
        logListPlus
        logFileList
        logGame
        logGameCommand
        logDeprecated
        logTilde
    }
    './func/argv': { 
        argv
        ghotiConfig 
    }
    './func/init': { init, downloadArchive }
    './structure/component': { component }
    './structure/page': { page }
    './structure/lambda': { lambda }
    './structure/func': { func }
    './structure/feature': { feature }
    './func/bark': { executeBkc }
    './func/parser/parser': { processMucall }
    './func/fix': { fix }
    './func/update': { update }
    './ame/init': { initUnderline }
    './ame/execute': { checkAme, executeAme }
    './eng/init': { minigame }
    './eng/frog': { frogGame }
    './func/file': { file }
    './func/suffix': { suffix }
    './func/pack': { pack }
    './ame/tilde/tilde': { addTilde, executeTilde }
}

const notValid = (env) ->
    logUnknown env
    process.exit!

const runPrefixCommand = (command, ghoti, ghotiCLIPath, env) ->
    if !Boolean command
    then notValid <| env
    if typeof command !== 'string'
    then notValid <| env
    if command.length < 1
    then notValid <| env
    var whenDone
    const prefix = command.substring 0, 1
    const suffix = command.substring 1, command.length
    switch prefix
        case '_'
            const ameResult = checkAme command
            if ameResult
            then (executeAme ameResult, env.texture, ghoti, logSymbol, env, ghotiCLIPath, process.cwd!)
            else notValid <| env
        case '!'
            whenDone = (logGameCommand!)
            frogGame ghoti, env, whenDone
        case '='
            logWhatIs suffix, env
        case '~'
            whenDone = logTilde!
            executeTilde suffix, env, whenDone
        default
            notValid <| env

const execute = (...mucall?) !->
    var whenDone, env
    const ghoti = ghotiConfig
    const ghotiCLIPath = cliPath!
    env = argv!
    if env
    # Update 2018-04-02
    # Fix length determine issue
    then 
        if mucall.length >= 1
        then env = processMucall env, mucall
    else 
        log '| Environment process Error'
        log '| Try "ghoti fix"'
        process.exit!
    const mode = env.mode.toLowerCase!
    switch mode

        # about
        case 'a'
            fallthrough
        case 'about'
            logAbout env

        # barklang
        case 'b'
            fallthrough
        case 'bk'
            fallthrough
        case 'bark'
            executeBkc env.texture[0]

        # empty
        case 'empty'
            logHelp true, env

        # version
        case 'v'
            fallthrough
        case 'version'
            logVersion env

        # help
        case '?'
            fallthrough
        case 'help'
            logHelp false, env

        # help plus
        case '?+'
            fallthrough
        case 'help+'
            logHelpMore env

        # status
        case 'stat'
            fallthrough
        case 'status'
            logStatus ghoti, env

        # download
        case 'd'
            fallthrough
        case 'install'
            fallthrough
        case 'download'
            whenDone = logCommand!
            downloadArchive ghotiCLIPath, env.texture[0], env.texture[1], whenDone, env

        # info
        case 'inf'
            fallthrough
        case 'info'
            logInfo env.texture[0], env

        # i
        case 'i'
            logDeprecated 'i', ['Confusing between "init" and "install"']

        # init
        case 'create'
            fallthrough
        case 'new'
            fallthrough
        case 'template'
            fallthrough
        case 'init'
            whenDone = logCommand!
            init ghotiCLIPath, env.texture[0], env.texture[1], whenDone, env

        case 'merge'
            fallthrough
        case 'mer'
            fallthrough
        case 'm'
            whenDone = logCommand!
            log 'Not a finished feature, check update'
            whenDone!

        # file
        case 'f'
            fallthrough
        case 'file'
            whenDone = logCommand!
            file ghotiCLIPath, env.texture[0], env.texture[1], whenDone, env

        # example
        case 'example'
            whenDone = logCommand!
            init ghotiCLIPath, 'ghoti-example', env.texture[0], whenDone, env
        
        # update
        case 'update'
            whenDone = logUpdate ghoti, env
            update whenDone, env

        # tilde
        case '~'
            fallthrough
        case 'tilde'
            whenDone = logTilde!
            addTilde whenDone

        # whatis
        case 'w'
            fallthrough
        case '='
            fallthrough
        case 'whatIs'
            fallthrough
        case 'what'
            fallthrough
        case 'whatis'
            logWhatIs env.texture[0], env

        # list
        case 'lt'
            fallthrough
        case 'types'
            fallthrough
        case 'list'
            logList env
        
        # list plus
        case 'lt+'
            fallthrough
        case 'types+'
            fallthrough
        case 'listPlus'
            fallthrough
        case 'list+'
            logListPlus env

        # listFile
        case 'lf'
            fallthrough
        case 'files'
            fallthrough
        case 'listFile'
            logFileList env

        # fix
        case 'issue'
            fallthrough
        case 'fix'
            whenDone = logCommand!
            fix env.texture, ghoti, whenDone, env

        # hint
        case 'hint'
            fallthrough
        case 'post'
            logPostNPMInstall env.texture[0], env

        # suffix
        case 'suffix'
            fallthrough
        case 'suff'
            fallthrough
        case 'suf'
            fallthrough
        case 's'
            whenDone = logCommand!
            suffix env.texture[0], env.texture[1], ghoti, whenDone, env

        # pack
        case 'pack'
            fallthrough
        case 'p'
            whenDone = logCommand!
            pack env.texture[0], env.texture[1], ghoti, whenDone, env

        # deploy and pack
        case 'deploy'
            fallthrough
        case 's&p'
            whenDone = logCommand!
            suffix env.texture[0], env.texture[1], ghoti, (!->
                pack env.texture[0], env.texture[1], ghoti, whenDone, env), env

        # lambda
        case '+l'
            fallthrough
        case 'lambda'
            whenDone = logCommand!
            lambda ghotiCLIPath, process.cwd!, env.texture[0], ghoti, whenDone, env
            whenDone!

        # feature
        case '+t'
            fallthrough
        case 'feature'
            whenDone = logCommand!
            feature ghotiCLIPath, process.cwd!, env.texture[0], ghoti, whenDone, env
            whenDone!
            
        # function
        case '+f'
            fallthrough
        case 'func'
            whenDone = logCommand!
            func ghotiCLIPath, process.cwd!, env.texture[0], ghoti, whenDone, env
            whenDone!
        case 'function'
            whenDone = logCommand 'function', 'func'
            func ghotiCLIPath, process.cwd!, env.texture[0], ghoti, whenDone, env
            whenDone!

        # page
        case '+p'
            fallthrough
        case 'page'
            whenDone = logCommand!
            page ghotiCLIPath, process.cwd!, env.texture[0], ghoti, whenDone, env
            whenDone!

        # component
        case '+c'
            fallthrough
        case 'component'
            whenDone = logCommand!
            component ghotiCLIPath, process.cwd!, env.texture[0], ghoti, whenDone, env
            whenDone!

        # underline
        case 'underline'
            whenDone = logUnderline!
            initUnderline ghoti, whenDone, env

        # game
        case 'g'
            fallthrough
        case 'game'
            fallthrough
        case 'minigame'
            whenDone = logGame!
            minigame ghoti, env, whenDone            
        default
            runPrefixCommand mode, ghoti, ghotiCLIPath, env

export execute
