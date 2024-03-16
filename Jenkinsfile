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
        stage('Build') {
            steps {
                echo "Building the docker image...."
                withCredentials([usernamePassword(credentialsId:'dockr-hub-repo', passwordVariable: 'PASS', usernameVariable: 'USER')]){
                    sh "docker build -t taqiyeddinedj/devsecops:webapp-1.0 ."
                    sh " echo $PASS | docker login -u $USER --password-stdin"
                    sh "docker push taqiyeddinedj/devsecops:webapp-1.0 ."
            }
        }
    }
}
}