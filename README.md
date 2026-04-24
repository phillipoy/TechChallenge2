# Tech Challenge 2 – GitOps Pipeline on AWS EKS (Argo CD + GitHub Actions)

## Overview

This branch implements a modern GitOps-based deployment pipeline using:

- GitHub Actions (CI)
- Amazon ECR (image storage)
- AWS EKS (Kubernetes)
- Argo CD (GitOps deployment)
- Helm (Kubernetes packaging)
- AWS ALB Ingress Controller

This setup replaces traditional CI/CD deployment with a Git-driven model.

> This branch uses GitOps (GitHub Actions + Argo CD).  
> See the `main` branch for the Jenkins-based CI/CD implementation.

---

## Architecture

GitHub → GitHub Actions → Build Docker Image → Push to ECR  
GitHub (gitops branch) → Argo CD → Helm → EKS  

User → ALB → Ingress → Service → Pods  

---

## Project Structure

.
├── .github/
│   └── workflows/
│       └── build-and-push.yml
├── helm/
│   └── tech-challenge-2/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── hpa.yaml
│           └── ingress.yaml
├── Dockerfile
├── README.md

---

## GitHub Actions (CI)

Triggered on push to the `gitops` branch.

Responsibilities:
- Build Docker image
- Push image to Amazon ECR

### Required GitHub Secrets

AWS_ACCESS_KEY_ID  
AWS_SECRET_ACCESS_KEY  

These credentials allow GitHub Actions to authenticate with AWS and push images to ECR.

---

## GitOps with Argo CD

Argo CD continuously monitors the GitHub repository and deploys changes automatically.

### Configuration

- Repository: This repo (`gitops` branch)
- Path: `helm/tech-challenge-2`
- Sync Policy:
  - Auto Sync enabled
  - Prune enabled
  - Self Heal enabled

### What Argo CD Does

- Pulls Helm chart from GitHub
- Deploys application to EKS
- Keeps cluster state in sync with Git

---

## Helm Chart

Helm is used to package Kubernetes resources.

### Key Files

- Chart.yaml → chart metadata
- values.yaml → configurable values
- templates/ → Kubernetes manifests

### Components Deployed

- Deployment
- Service
- Horizontal Pod Autoscaler (HPA)
- Ingress (ALB)

---

## Scaling (HPA)

- Min replicas: 1
- Max replicas: 12
- CPU target: 50%

Kubernetes automatically scales pods based on CPU usage.

---

## Load Testing

Example using Siege:

siege -c 250 -t 2M http://<ALB-DNS>

This simulates traffic and triggers auto-scaling.

---

## Accessing the Application

Get ALB URL:

kubectl get ingress  

Open in browser:

http://<ALB-DNS>

---

## Accessing Argo CD

Port forward from EC2:

ssh -i <key>.pem -L 8081:localhost:8081 ubuntu@<EC2-IP>  

Open:

https://localhost:8081  

Login:
- Username: admin  
- Password:

kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d  

---

## Key Concepts

- GitOps deployment model
- CI with GitHub Actions
- Continuous delivery with Argo CD
- Helm templating for Kubernetes
- Auto-scaling with HPA
- Secure AWS access using IAM
- ALB Ingress for public access

---

## Summary

This project demonstrates a fully automated GitOps pipeline where:

- Code changes trigger image builds
- Argo CD automatically deploys updates
- Kubernetes maintains the desired state

---

## One Line Summary

End-to-end GitOps deployment using GitHub Actions, Argo CD, and Kubernetes on AWS EKS.