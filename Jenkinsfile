pipeline {
    agent any

    environment {
        AWS_REGION     = 'us-east-1'
        AWS_ACCOUNT_ID = '113645088585'
        ECR_REPO       = 'tech-challenge-2-hello-flask'
        IMAGE_TAG      = 'latest'
        IMAGE_URI      = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Pulling code from GitHub...'
                checkout scm
            }
        }

        stage('Verify Tools') {
            steps {
                echo 'Checking installed tools...'
                sh '''
                    aws --version
                    docker --version
                    git --version
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh '''
                    docker build -t ${ECR_REPO}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Login to ECR') {
            steps {
                echo 'Logging into Amazon ECR...'
                sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                '''
            }
        }

        stage('Tag Docker Image') {
            steps {
                echo 'Tagging Docker image for ECR...'
                sh '''
                    docker tag ${ECR_REPO}:${IMAGE_TAG} ${IMAGE_URI}
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker image to ECR...'
                sh '''
                    docker push ${IMAGE_URI}
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline finished successfully. Docker image pushed to ECR.'
        }
        failure {
            echo 'Pipeline failed. Check the logs.'
        }
    }
}