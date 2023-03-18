pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "eu-west-2"
    }

    stages {
      stage("Create Nginx-controller") {
            steps {
                script {
                    dir('Nginx-Controller') {
                       sh "aws eks --region eu-west-2 update-kubeconfig --name stevo"
                        sh "terraform init && terraform plan"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }

       stage("Create Prometheus") {
            steps {
                script {
                    dir('Prometheus-Helm') {
                        sh "terraform init && terraform plan"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }

        stage("Deploy Voting App to EKS") {
            steps {
                script {
                    dir('Vote-App') {
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }

        stage("Deploy Microservice to EKS") {
            steps {
                script {
                    dir('Microservice') {
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }
         
       stage("Deploy Ingress rule to EKS") {
            steps {
                script {
                    dir('Ingress-Rule') {
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }
    }
}
