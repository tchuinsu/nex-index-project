# nex-index-project

gpt jenkinsflie:

pipeline {
    agent any

    environment {
        IMAGE_NAME = 'tchuinsu/nex-index'
    }

    parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'main', description: 'Git branch to build')
    }

    stages {
        stage('Clone Repository') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "*/${params.BRANCH_NAME}"]],
                    userRemoteConfigs: [[
                        url: 'git@github.com:tchuinsu/nex-index-project.git',
                        credentialsId: 'github-auth'
                    ]]
                ])
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t ${IMAGE_NAME} .
                    docker images | grep ${IMAGE_NAME}
                """
            }
        }

        stage('Login and Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-auth', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh """
                        echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin
                        docker push ${IMAGE_NAME}
                    """
                }
            }
        }

        stage('Run Container') {
            steps {
                sh """
                    docker rm -f nex-index || true
                    docker run -d -p 8080:80 --name nex-index ${IMAGE_NAME}
                """
            }
        }
    }

    post {
        always {
            echo 'Build complete. Visit http://<your-server-ip>:8080 to view the app.'
        }
    }
}






# Base image
FROM ubuntu:20.04

LABEL maintainer="yourname@example.com"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y apache2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./index.html /var/www/html/index.html

EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]