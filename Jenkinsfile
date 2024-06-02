pipeline {
    agent any
    tools{
        go 'go1.22.1'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        //SONAR_TOKEN = credentials('SONAR_TOKEN') // Reference Jenkins credential ID
    }
    stages{
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/taqiyeddinedj/devsecops.git'
            }
        }
        stage("Sonarqube Analysis") {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=devsecops \
                    -Dsonar.projectKey=devsecops \
                    -Dsonar.sources=. \
                    -Dsonar.host.url=http://10.231.10.19:9000 \
                    -Dsonar.login=sqp_6d30916e2ff8083c6dd9846fb93f0300f17e2c99'''
                }
            }
        }
        // i removed quality gate and the delay 
        
        stage("Delay") {
            steps {
                // Add a 30-second delay for Merge Requests
                sleep time: 30, unit: 'SECONDS'
            }
        }
        stage("quality gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
                }
            }
        }
        
        // OWASP stage has been removed here
        
        stage('Build') {
            steps {
                echo "Building the docker image...."
                withCredentials([usernamePassword(credentialsId:'docker-token', passwordVariable: 'PASS', usernameVariable: 'USER')]){
                    //sh "docker build -t taqiyeddinedj/devsecops:webapp-1.0 ."
                    //sh " echo $PASS | docker login -u $USER --password-stdin"
                    //sh "docker push taqiyeddinedj/devsecops:webapp-1.0"
                    sh "docker build -t taqiyeddinedj/devsecops:webapp-${BUILD_NUMBER} ."
                    sh " echo $PASS | docker login -u $USER --password-stdin"
                    sh "docker push taqiyeddinedj/devsecops:webapp-${BUILD_NUMBER}"
            }
        }
    }
        stage('Trivy') {
            steps{
                //sh 'trivy image taqiyeddinedj/devsecops:webapp-1.0 > trivyResult.txt'
                sh "trivy image taqiyeddinedj/devsecops:webapp-${BUILD_NUMBER} > trivyResult.txt"
            }
        }
        

        stage('Trigger ManifestUpdate') {
                    steps {
                        echo "triggering updatemanifestjob"
                        build job: 'updatemanifest', parameters: [string(name: 'DOCKERTAG', value: env.BUILD_NUMBER)]
                    }
                }

    }


    post {
        always {
            emailext attachLog: true,
                subject: "'${currentBuild.result}'",
                body: "Project: ${env.JOB_NAME}<br/>" +
                    "Build Number: ${env.BUILD_NUMBER}<br/>" +
                    "URL: ${env.BUILD_URL}<br/>",
                to: 'touk.shurrle@gmail.com',
                attachmentsPattern: 'trivyResult.txt'
        }
    }


}


