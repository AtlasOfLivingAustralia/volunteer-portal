import java.text.SimpleDateFormat

eventCompileStart = { kind ->
    def buildNumber = metadata.'app.buildNumber'

    if (!buildNumber)
        buildNumber = 1
    else
        buildNumber = Integer.valueOf(buildNumber) + 1

    metadata.'app.buildNumber' = buildNumber.toString()

    def formatter = new SimpleDateFormat("dd MMM, yyyy")
    def buildDate = formatter.format(new Date(System.currentTimeMillis()))
    metadata.'app.buildDate' = buildDate
    metadata.'app.buildProfile' = grailsEnv

    metadata.persist()

    println "**** Compile Starting on Build #${buildNumber}"
}

