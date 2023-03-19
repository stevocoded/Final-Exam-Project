pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "eu-west-2"
    }
    stages {
        stage("Deploy Voting App to EKS") {
            steps {
                dir('Vote-App') {
                    sh "pwd"
                    sh "aws eks --region ${env.AWS_DEFAULT_REGION} update-kubeconfig --name stevo"
                    sh "terraform init && terraform plan"
                    sh "terraform apply -auto-approve"
                }
            }
        }
        
        stage("Deploy Microservice to EKS") {
            steps {
                dir('Microservice') {
                    sh "aws eks --region ${env.AWS_DEFAULT_REGION} update-kubeconfig --name stevo"
                    sh "terraform init"
                    sh "terraform apply -auto-approve"
                }
            }
        }
    }
}
