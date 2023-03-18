pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "eu-west-2"
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {
        stage("Create Nginx Controller") {
            steps {
                dir('Nginx-Controller') {
                    sh "aws eks --region $AWS_DEFAULT_REGION update-kubeconfig --name stevo"
                    sh "terraform init && terraform apply -auto-approve"
                }
            }
        }

        stage("Create Prometheus") {
            steps {
                dir('Prometheus-Helm') {
                    sh "terraform init && terraform apply -auto-approve"
                }
            }
        }

        stage("Deploy Voting App to EKS") {
            steps {
                dir('Vote-App') {
                    sh "terraform init && terraform apply -auto-approve"
                }
            }
        }

        stage("Deploy Microservice to EKS") {
            steps {
                dir('Microservice') {
                    sh "terraform init && terraform apply -auto-approve"
                }
            }
        }

        stage("Deploy Ingress rule to EKS") {
            steps {
                dir('Ingress-Rule') {
                    sh "terraform init && terraform apply -auto-approve"
                }
            }
        }
    }
}
