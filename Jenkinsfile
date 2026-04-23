pipeline {
    agent any

    environment {
        AWS_REGION     = 'us-east-1'
        AWS_ACCOUNT_ID = '113645088585'
        ECR_REPO       = 'tech-challenge-2-hello-flask'
        IMAGE_TAG      = 'latest'
        IMAGE_URI      = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
        CLUSTER_NAME   = 'Tech-Challenge-2-EKS-Cluster'
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo 'Pulling latest code from GitHub...'
                checkout scm
                sh 'ls -R'   // 👈 helps verify Jenkins is using repo files
            }
        }

        stage('Verify Tools') {
            steps {
                echo 'Checking installed tools...'
                sh '''
                    aws --version
                    docker --version
                    git --version
                    kubectl version --client
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
                    aws ecr get-login-password --region ${AWS_REGION} \
                    | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                '''
            }
        }

        stage('Tag Docker Image') {
            steps {
                echo 'Tagging Docker image...'
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

        stage('Update Kubeconfig') {
            steps {
                echo 'Connecting to EKS cluster...'
                sh '''
                    aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying application (Deployment + Service + HPA)...'
                sh '''
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    kubectl apply -f k8s/hpa.yaml
                '''
            }
        }

        stage('Deploy Ingress (ALB)') {
            steps {
                echo 'Creating ALB via Ingress...'
                sh '''
                    kubectl apply -f k8s/ingress.yaml
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Checking Kubernetes resources...'
                sh '''
                    kubectl get nodes
                    kubectl get pods
                    kubectl get svc
                    kubectl get hpa
                    kubectl get ingress
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline finished successfully. App deployed and exposed via ALB.'
        }
        failure {
            echo 'Pipeline failed. Check logs for errors.'
        }
    }
}