def getWorkspace() {
    pwd().replace("%2F", "__")
}

node('') {
    ws(getWorkspace()) {
        final pipelineName = env.JOB_NAME.replace("%2F", "/")
        final buildNumber = env.BUILD_DISPLAY_NAME
        final branchName = env.BRANCH_NAME
        final buildUrl = env.BUILD_URL

        // remove the preceding 'MB-' of the pipeline name and remove the branch
        final fullServiceName = pipelineName.replaceAll("(?:MB-)?([\\w-]+)(?:(?:%2F|/)[\\w-\\.]+)*", "\$1")

        def LAST_STAGE_NAME = ""

        def TAG
        def buildEnv = ""
        def kubEnv = "test-"

        def envServiceName = kubEnv + fullServiceName

        try {

            stage('Checkout') {
                LAST_STAGE_NAME = env.STAGE_NAME
                echo "Checking out ${branchName}..."
                //noinspection GroovyAssignabilityCheck
                checkout scm
                helmEnv = branchName.replace("master", "prod").replace("develop", "dev").replaceAll("release/.*", "stage")
                buildEnv = helmEnv.replaceAll("hotfix/.*", "prod").replaceAll("bugfix/.*", "stage").replaceAll("feature/.*", "dev").capitalize()
                helmEnv = helmEnv.replaceAll("hotfix/.*", "").replaceAll("bugfix/.*", "").replaceAll("feature/.*", "")
            }



            // if branchname contains an url encoded slash, replace it with a slash
            pipelineName = pipelineName.replace("%2F", "/")

            echo "Starting Pipeline..."

            stage('Config') {
                LAST_STAGE_NAME = env.STAGE_NAME
                echo "Getting Config..."

            }

                echo "Spawning docker container..."

                docker.image('docker-php-nginx:7.4').inside {
                    stage('PHP Build') {
                        LAST_STAGE_NAME = env.STAGE_NAME
                        echo "Running PHP Build..."
                        sh 'composer install'

                    }

                    stage('Create Artifact'){
                        def exists = fileExists 'release.tar.gz'

                        if (exists) {
                           sh 'rm release.tar.gz'
                        }

                        sh 'tar -zcvf release.tar.gz ./*'
                    }

                }






            stage('Deployment') {

                currentBuild.result = 'SUCCESS'
             }


        } catch (e) {
            echo "Throwing Exception \"${e}\" --- Pipeline was not successful!"
           // slackSend(channel: slackRecipient, color: '#FF0000', message: "*Pipeline-Name:* ${pipelineName} \n*Build-Nummer:* ${buildNumber} \n"
           //         + "*Branch-Name:* ${branchName}\n:jenkins-failed: Pipeline failed in Step \"${LAST_STAGE_NAME}\"! (<${buildUrl}|Open>)")
            currentBuild.result = 'FAILED'      // Set result of currentBuild !Important!
            // Since we're catching the exception in order to report on it, we need to re-throw it, to ensure that the build is marked as failed
            throw e
        } finally {
         
            if (currentBuild.result == 'SUCCESS') {
            //    slackSend(channel: slackRecipient, color: 'good', message: "*Pipeline-Name:* ${pipelineName} \n*Build-Nummer:* ${buildNumber} \n"
            //            + "*Branch-Name:* ${branchName}\n:white_check_mark: Pipeline finished (<${buildUrl}|Open>)")
            }
        }
    }
}
