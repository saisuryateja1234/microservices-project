pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t suryadoc321/service:v1 .'
            }
        }
        stage("Push"){
            steps{
                script{
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        sh 'docker push suryadoc321/service:v1'
                    }
                }
            }
        }
    }
}
