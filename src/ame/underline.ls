require! {
    path
    '../log/std': { log, logPad, logHalfPad }
    '../func/config': { getConfig, writeConfig }
}

const underline = (ghoti) ->
    ghoti

const puls = (name) ->
    name

const minus = (name) ->
    name

const mergeGhoti = (ghoti, pathE, re) ->
    const path = JSON.parse JSON.stringify pathE
    const newGhoti = JSON.parse JSON.stringify ghoti
    var subPath
    subPath = newGhoti.underline.path
    const endPath = path.pop!
    for i in path
        if subPath.child
        then for j in subPath.child
            if j.name === i
            then 
                subPath = j
                break
        else for j in subPath
            if j.name === i
            then 
                subPath = j
                break
    if subPath.child
    then for i to subPath.child.length - 1
        if subPath.child[i].name === endPath
        then subPath.child[i] = re
    else for i to subPath.length - 1
        if subPath[i].name === endPath
        then subPath[i] = re
    newGhoti

const calculateNewUnderlinePlus = (currentE, name, whenDone) ->
    const current = JSON.parse JSON.stringify currentE
    if current.type === 'task'
    then 
        logPad '| New task must be created in a "set" not a "task"', 1
        logPad '| You can use "ghoti _[somepath]_|" to create a "set"', 1
        whenDone!
        process.exit!
    else
        if current.child
        then current.child.push {
            name
            type: 'task'
            prog: 0
        }
        else if current.push
        then current.push {
            name
            type: 'task'
            prog: 0
        }
        else
            logPad '| Unknown error', 1
            process.exit!
    current

const calculateProgress = (current, whenDone, doLog? = false, logLevel? = 1) ->
    var total, amount
    total = 0
    amount = 0
    const calculateProgressRecursion = (Rcurrent, level) ->
        if !Boolean Rcurrent.type
        then
            for i in Rcurrent
                calculateProgressRecursion i, level
        else
            if Rcurrent.type === 'task'
            then 
                if doLog
                then 
                    if level <= logLevel
                    then logHalfPad '| ' + Rcurrent.name + ' > Progress:' + Rcurrent.prog + '%', level
                amount += Rcurrent.prog
                total += 1
            else
                if doLog
                then 
                    if level <= logLevel
                    then logHalfPad '* ' + Rcurrent.name + ' > Size:' + Rcurrent.child.length, level
                for i in Rcurrent.child
                    calculateProgressRecursion i, level + 1
        void
    calculateProgressRecursion current, 0
    {
        total
        amount
    }

export underline
export puls
export minus
export mergeGhoti
export calculateProgress
export calculateNewUnderlinePlus