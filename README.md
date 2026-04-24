# Tech Challenge 2 – Jenkins CI/CD on AWS EKS

## Overview

This branch implements a traditional CI/CD pipeline using:

- Jenkins (CI/CD)
- Docker
- Amazon ECR (container registry)
- AWS EKS (Kubernetes)
- Kubernetes (Deployment, Service, HPA, Ingress)
- AWS ALB Ingress Controller

> This branch uses a Jenkins-based CI/CD pipeline.  
> See the `gitops` branch for the GitOps implementation using GitHub Actions and Argo CD.

---

## Architecture

GitHub → Jenkins → Build Docker Image → Push to ECR → Deploy to EKS (kubectl)  

User → ALB → Ingress → Service → Pods  

---

## Project Structure

.
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── hpa.yaml
│   └── ingress.yaml
├── terraform/
├── Dockerfile
├── Jenkinsfile
├── README.md

---

## Jenkins Pipeline

The Jenkins pipeline automates:

- Pulling code from GitHub
- Building a Docker image
- Logging into Amazon ECR
- Tagging and pushing the image
- Connecting to EKS
- Deploying Kubernetes resources

### Pipeline Stages

- Checkout Code
- Verify Tools
- Build Docker Image
- Login to ECR
- Tag Image
- Push Image
- Update kubeconfig
- Deploy to EKS
- Deploy Ingress
- Verify Deployment

---

## Kubernetes Deployment

Resources deployed:

- Deployment → runs the application pods
- Service → exposes pods internally
- Horizontal Pod Autoscaler (HPA) → handles scaling
- Ingress (ALB) → exposes app publicly

---

## Scaling (HPA)

- Min replicas: 1
- Max replicas: 12
- CPU threshold: 50%

The application automatically scales based on CPU usage.

---

## Load Testing

Example using Siege:

siege -c 250 -t 2M http://<ALB-DNS>

This simulates traffic and triggers scaling.

---

## Accessing the Application

Get the load balancer URL:

kubectl get ingress  

Open in browser:

http://<ALB-DNS>

---

## Terraform

Terraform provisions:

- EKS cluster
- Node groups
- IAM roles and permissions
- Networking resources

---

## Key Concepts

- CI/CD pipeline using Jenkins
- Docker image lifecycle (build → push → deploy)
- Kubernetes deployments and services
- Auto-scaling with HPA
- AWS IAM best practices
- ALB Ingress for external access

---

## Summary

This project demonstrates a complete Jenkins-based CI/CD pipeline deploying a containerized application to AWS EKS with auto-scaling and public access.

---

## One Line Summary

End-to-end CI/CD pipeline using Jenkins to deploy a containerized app to Kubernetes on AWS EKS.