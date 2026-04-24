# Tech Challenge 2 – CI/CD + GitOps on AWS EKS

## Overview

This project implements a complete cloud-native deployment pipeline using:

- AWS EKS (Kubernetes)
- Docker + Amazon ECR
- Jenkins (CI/CD)
- GitHub Actions (CI alternative)
- Argo CD (GitOps)
- Helm (Kubernetes packaging)
- AWS ALB Ingress Controller

It demonstrates both:
- Traditional CI/CD (Jenkins)
- Modern GitOps (GitHub Actions + Argo CD)

---

## Architecture

GitHub → CI  
- Jenkins → Build → Push → Deploy (kubectl)  
- GitHub Actions → Build → Push → ECR  

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
├── k8s/
├── terraform/
├── Dockerfile
├── Jenkinsfile

---

## Branch Strategy

- main → Jenkins pipeline  
- gitops → GitHub Actions + Argo CD  

---

## Jenkins CI/CD Pipeline

Handles:
- Pulling code from GitHub  
- Building Docker image  
- Pushing to ECR  
- Deploying to EKS using kubectl  

---

## GitHub Actions CI

Triggered on push to gitops branch.

Performs:
- Build Docker image  
- Push to ECR  

### Required Secrets

AWS_ACCESS_KEY_ID  
AWS_SECRET_ACCESS_KEY  

---

## GitOps with Argo CD

Argo CD:
- Watches gitops branch  
- Deploys Helm chart from helm/tech-challenge-2  
- Automatically syncs changes  

### Sync Settings

- Auto Sync enabled  
- Prune enabled  
- Self Heal enabled  

---

## Helm Chart

Used to package Kubernetes resources.

- Chart.yaml → metadata  
- values.yaml → configuration  
- templates → Kubernetes manifests  

---

## Scaling (HPA)

- Min replicas: 1  
- Max replicas: 12  
- CPU target: 50%  

---

## Load Testing

siege -c 250 -t 2M http://<ALB-DNS>

---

## Accessing the Application

kubectl get ingress  

Open in browser:  
http://<ALB-DNS>

---

## Accessing Argo CD

ssh -i <key>.pem -L 8081:localhost:8081 ubuntu@<EC2-IP>  

Open:  
https://localhost:8081  

Login:  
Username: admin  

Get password:  
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d  

---

## Terraform

Terraform provisions:
- EKS cluster  
- Node groups  
- IAM roles  
- Networking  

---

## Key Concepts

- CI/CD vs GitOps  
- Kubernetes deployments and services  
- Helm templating  
- AWS IAM best practices  
- Auto-scaling with HPA  
- ALB Ingress for public access  

---

## Summary

This project demonstrates a fully automated, production-style deployment pipeline using both CI/CD and GitOps on AWS.

---

## One Line Summary

End-to-end Kubernetes deployment using Jenkins, GitHub Actions, and Argo CD on AWS EKS.