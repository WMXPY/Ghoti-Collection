require! {
    path
    fs
    os
    'child_process': { spawn }
    '../../func/config': { writeCLIConfig, readCLIConfig }
    '../../log/std': { log, logPad }
    '../../func/deepclone': { deepClone, uniqueId }
    './download': { downloadFile }
}

const downloadPack = (uri, filename, callback) ->
    downloadFile uri, filename, (err) ->
        if err
        then 
            log '| Err ' + err.toString!
            process.exit!
        else callback!
    void

const parseLink = (linkE, whenDone) ->
    const splited = linkE.split /:\/\/|\//g
    if splited.length <= 0
    then
        log '| Not a vaild link'
        whenDone!
        process.exit!
    const protocal = (splited.shift!).toLowerCase!
    var link, next
    switch protocal
        case 'github'
            next = 'download'
            link = 'https://raw.githubusercontent.com/' + (splited.join '/')
        case 'file'
            next = 'file'
            link = linkE
        default
            log '| Not a vaild link'
            whenDone!
            process.exit!
    {
        next
        link
    }

const expendPack = (filePath, targetPath, whenDone, callback) ->
    switch os.platform!
        case 'win32'
            archiveWin32 filePath, targetPath, whenDone, callback
        case 'darwin'
            command = 1
        default
            command = 1

const addExternal = (cliConfigE, ghotiinstallE, expackPath, whenDone) ->
    cliConfig = deepClone cliConfigE
    if cliConfig.external
    then 
        if cliConfig.external.length
        then 
            for i in cliConfig.external
            then 
                if i.name === ghotiinstallE.name
                then 
                    log '| ghotiinstall name alreay exist'
                    whenDone!
                    process.exit!
    else 
        log '| CLI config file is not valid'
        whenDone!
        process.exit!
    ghotiinstall = deepClone ghotiinstallE
    ghotiinstall.path = expackPath
    cliConfig.external.push ghotiinstall
    writeCLIConfig cliConfig

const excuteExternal = (ghoti_path, type, targetPath, whenDone, env, callback) ->
    const cliConfig = readCLIConfig!
    var external
    if cliConfig.external
    then 
        for i in cliConfig.external
        then 
            if i.name === type
            then 
                external = i
                log i
    else
        log '| ghoti config file is not exist in storage list'
        log '| Try to reinstall ghoti-cli by "sudo npm -g install ghoti-cli"'
        whenDone!
        process.exit!
    if external
    then
        log external
    else
        const { link, next } = parseLink type, whenDone
        switch next
            case 'download'
                # FOR PRODUCTION
                
                const id = uniqueId!

                # FOR TESTING

                # const id = '_5gbu4tisu'
                const downloadPath = path.join ghoti_path, 'external', (id + '.zip')
                const expendPath = path.join ghoti_path, 'external', id

                # FOR PRODUCTION

                downloadPack link, downloadPath, ->
                    log '--- DOWNLOAD COMPLETED ---'
                    log '| PACKAGE UNIQUEID: ' + id
                    expendPack downloadPath, expendPath, whenDone, (ghotiinstall) ->
                        addExternal cliConfig, ghotiinstall, expendPath, whenDone
                        callback expendPath, ghotiinstall

                # FOR TESTING

                # expendPack downloadPath, expendPath, whenDone, (ghotiinstall) ->
                #     addExternal cliConfig, ghotiinstall, expendPath
                #     callback expendPath, ghotiinstall
                
            case 'file'
                log next
            default
                log '| Not a vaild link'
                whenDone!
                process.exit!
    void

const archiveWin32 = (filePath, targetPath, whenDone, callback) ->
    const unzip = spawn 'unzip', [
        '-o'
        filePath
        '-d'
        targetPath
    ]
    unzip.on 'exit', (code) ->
        if code === 0
        then 
            log '---  UNPACK COMPLETED  ---'
            const tempFilePath = path.join targetPath, '.ghotiinstall'
            if fs.existsSync tempFilePath
            then (callback (JSON.parse (fs.readFileSync tempFilePath, 'utf8')))
            else 
                log '| Target pack have no .ghotiinstall file'
                whenDone!
                process.exit!
        else
            log '| Unzip failed'
            whenDone!
            process.exit!

export excuteExternal