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
        stage('Update Git Repository') {
            steps {
                // Check out the Git repository
                git branch: 'main', url: 'https://github.com/taqiyeddinedj/devsecops.git'

                // Replace the image tag in the Kubernetes manifest files
                sh "sed -i 's|taqiyeddinedj/devsecops:.*|taqiyeddinedj/devsecops:webapp-${BUILD_NUMBER}|g' manifests/deploy.yaml"

                // Add, commit, and push the changes to the Git repository
                withCredentials([usernamePassword(credentialsId: 'github-token', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                    sh """
                        git config --global user.email "djouani.taqiyeddine@gmail.com"
                        git config --global user.name "${GIT_USERNAME}"
                        git add manifests/deploy.yaml
                        git commit -m "Update image tag to ${BUILD_NUMBER}"
                        git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/taqiyeddinedj/devsecops.git main
                    """
                }

            }
}
        stage('Deploy to kubernetes using ArgoCD'){
            steps{
                withKubeConfig(caCertificate: '', clusterName: 'default', contextName: '', credentialsId: 'k8s-cred', namespace: 'devsecops', restrictKubeConfigAccess: false, serverUrl: 'https://10.231.10.16:6443') {
                        //sh "sed -i 's|taqiyeddinedj/devsecops:webapp-1.0|taqiyeddinedj/devsecops:${BUILD_NUMBER}|g' manifests/deploy.yaml"
                        sh "kubectl apply -f application.yaml"
                }
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
                attachmentsPattern: 'trivyimage.txt'
            }
        }
}
