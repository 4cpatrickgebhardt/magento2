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
        def helmEnv = ""

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

            docker.withRegistry('https://registry.dsp.atu.de:443/', 'docker_download') {
                docker.image('atu_dev/docker-tools-php-npm:node-8.9.4').inside {
                    stage('RM old dependencies') {
                       sh '[ ! -e node_modules ] || sudo chown $USER:$USER node_modules'
                       sh '[ ! -e package-lock.json ] || sudo chown $USER:$USER package-lock.json'
                       sh "[ ! -e node_modules ] || sudo  rm -rf node_modules"
                       sh "[ ! -e package-lock.json ] || sudo rm package-lock.json"
                    }
                }

                echo "Spawning docker container..."

                docker.image('atu_dev/docker-tools-php:master').inside {
                    stage('PHP Build') {
                        LAST_STAGE_NAME = env.STAGE_NAME
                        echo "Running PHP Build..."
                        sh 'composer install'

                    }
                }

                docker.image('atu_dev/docker-tools-php-npm:node-8.9.4').inside {
                    stage('PHP Build-Step2') {
                        LAST_STAGE_NAME = env.STAGE_NAME
                        echo "Running PHP Build-Step2..."
                        //sh 'sudo npm cache clean --force --unsafe-perm'
                        sh "sudo PATH=$PATH:./node_modules/.bin npm install"

                        sh 'sudo npm run build'

                        def exists = fileExists 'release.tar.gz'

                        if (exists) {
                           sh 'rm release.tar.gz'
                        }

                        sh 'tar -zcvf release.tar.gz ./*'
                    }
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
            notifyBitbucket()

            if (currentBuild.result == 'SUCCESS') {
            //    slackSend(channel: slackRecipient, color: 'good', message: "*Pipeline-Name:* ${pipelineName} \n*Build-Nummer:* ${buildNumber} \n"
            //            + "*Branch-Name:* ${branchName}\n:white_check_mark: Pipeline finished (<${buildUrl}|Open>)")
            }
        }
    }
}
