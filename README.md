[README.md](https://github.com/user-attachments/files/28437843/README.md)
# 🛒 Cloud-Native E-Commerce Microservices — DevOps Pipeline on AWS EKS

![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![AWS](https://img.shields.io/badge/AWS_EKS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)
![gRPC](https://img.shields.io/badge/gRPC-4285F4?style=for-the-badge&logo=google&logoColor=white)

> **A production-grade, cloud-native microservices e-commerce application — fully containerized, orchestrated on AWS EKS, and deployed via an automated Jenkins CI/CD pipeline.**

---

## 🚀 Project Overview

This project demonstrates a **real-world DevOps implementation** of Google's [Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo) — a fully distributed e-commerce platform broken into **11 independent microservices**. Each service is containerized with Docker, deployed to **Amazon EKS (Elastic Kubernetes Service)**, and released automatically via a **Jenkins CI/CD pipeline**.

The focus of this project is the **DevOps infrastructure layer** — designing Kubernetes manifests, setting up automated deployments, configuring health probes, and managing service-to-service communication in a cloud environment.

---

## 🏗️ Architecture

```
                        ┌─────────────────────────────────────────────────┐
                        │              AWS EKS Cluster (ap-south-1)        │
                        │   Namespace: webapps                             │
                        │                                                  │
         ┌──────────┐   │   ┌──────────────────────────────────────────┐  │
         │  Jenkins │──────▶│  kubectl apply -f deployment-service.yml │  │
         │ Pipeline │   │   └──────────────────────────────────────────┘  │
         └──────────┘   │                                                  │
                        │   ┌────────────────────────────────────────┐    │
    User ──────────────────▶│  frontend (LoadBalancer / NodePort :80) │    │
                        │   └──────┬─────────────────────────────────┘    │
                        │          │  gRPC calls                           │
                        │   ┌──────▼───────────────────────────────────┐  │
                        │   │         Internal ClusterIP Services       │  │
                        │   │                                           │  │
                        │   │  checkoutservice   ◀──── paymentservice   │  │
                        │   │       │                                   │  │
                        │   │       ├──── productcatalogservice         │  │
                        │   │       ├──── shippingservice               │  │
                        │   │       ├──── emailservice                  │  │
                        │   │       ├──── currencyservice               │  │
                        │   │       └──── cartservice ◀── redis-cart    │  │
                        │   │                                           │  │
                        │   │  recommendationservice                    │  │
                        │   │  adservice                                │  │
                        │   │  loadgenerator (10 simulated users)       │  │
                        │   └───────────────────────────────────────────┘  │
                        └─────────────────────────────────────────────────┘
```

---

## 🧩 Microservices Breakdown

| Service | Protocol | Port | Responsibility |
|---|---|---|---|
| **frontend** | HTTP | 8080 | Web UI — serves the storefront to users |
| **checkoutservice** | gRPC | 5050 | Orchestrates the checkout flow |
| **productcatalogservice** | gRPC | 3550 | Lists and serves product data |
| **cartservice** | gRPC | 7070 | Manages user shopping cart (backed by Redis) |
| **recommendationservice** | gRPC | 8080 | Suggests related products |
| **paymentservice** | gRPC | 50051 | Processes payment transactions |
| **shippingservice** | gRPC | 50051 | Calculates shipping costs and dispatches |
| **emailservice** | gRPC | 5000 | Sends order confirmation emails |
| **currencyservice** | gRPC | 7000 | Converts prices across currencies |
| **adservice** | gRPC | 9555 | Serves context-based advertisements |
| **redis-cart** | TCP | 6379 | In-memory store for cart data |
| **loadgenerator** | HTTP | — | Simulates 10 concurrent users for testing |

---

## ⚙️ DevOps Implementation Highlights

### 🔁 Jenkins CI/CD Pipeline
```groovy
pipeline {
    agent any
    stages {
        stage('Deploy To Kubernetes') {
            // Deploys all 11 services to AWS EKS using stored k8-token credentials
        }
        stage('Verify Deployment') {
            // Confirms all services are running with: kubectl get svc -n webapps
        }
    }
}
```
- Automated deployment triggered on every push
- Kubernetes credentials managed securely via Jenkins credential store
- Targets `webapps` namespace on a dedicated EKS cluster

### ☸️ Kubernetes Features Used
- **Deployments** with rolling update strategy for zero-downtime releases
- **ClusterIP Services** for secure internal service-to-service communication
- **LoadBalancer Service** for public-facing frontend access
- **NodePort Service** for development/testing access
- **Liveness & Readiness Probes** on every service for self-healing
- **Resource Requests & Limits** (CPU/Memory) for efficient scheduling
- **Security Contexts** — non-root users, dropped capabilities, read-only root filesystem
- **gRPC Health Probes** (`/bin/grpc_health_probe`) for all gRPC services
- **Persistent Volume** for Redis cart data (`emptyDir`)

### 🔒 Security Best Practices Applied
- Containers run as **non-root user** (`runAsUser: 1000`)
- **`allowPrivilegeEscalation: false`** on sensitive services
- **Read-only root filesystem** on email and load generator services
- All capabilities dropped (`drop: [ALL]`) where applicable
- Service accounts scoped per deployment

---

## 🛠️ Tech Stack

| Category | Technology |
|---|---|
| **Container Orchestration** | Kubernetes (AWS EKS) |
| **Cloud Provider** | Amazon Web Services (AWS) |
| **CI/CD** | Jenkins |
| **Containerization** | Docker |
| **Inter-service Communication** | gRPC |
| **Cache / Session Store** | Redis |
| **Cluster Region** | ap-south-1 (Mumbai) |
| **Namespace** | webapps |

---

## 📋 Prerequisites

Before deploying, ensure you have:

- AWS CLI configured with appropriate IAM permissions
- `kubectl` installed and configured
- EKS cluster running (`EKS-1` in `ap-south-1`)
- Jenkins server with:
  - Kubernetes credentials plugin installed
  - `k8-token` credential configured
  - Access to the EKS cluster API endpoint

---

## 🚀 Deployment

### 1. Clone the repository
```bash
git clone https://github.com/usubbu/microservices-project.git
cd microservices-project
```

### 2. Configure kubectl for EKS
```bash
aws eks update-kubeconfig --region ap-south-1 --name EKS-1
```

### 3. Create the namespace
```bash
kubectl create namespace webapps
```

### 4. Deploy all services manually
```bash
kubectl apply -f deployment-service.yml -n webapps
```

### 5. Verify all services are running
```bash
kubectl get pods -n webapps
kubectl get svc -n webapps
```

### 6. Access the application
```bash
# Get the external LoadBalancer URL
kubectl get svc frontend-external -n webapps
```
Open the `EXTERNAL-IP` in your browser to access the e-commerce storefront.

---

## 🔄 CI/CD Pipeline Flow

```
Developer pushes code
        │
        ▼
   Jenkins picks up job
        │
        ▼
   Stage 1: Deploy to Kubernetes
   └── withKubeCredentials (k8-token)
   └── kubectl apply -f deployment-service.yml
        │
        ▼
   Stage 2: Verify Deployment
   └── kubectl get svc -n webapps
        │
        ▼
   ✅ All 11 services running on AWS EKS
```

---

## 📊 Resource Configuration Summary

| Service | CPU Request | CPU Limit | Memory Request | Memory Limit |
|---|---|---|---|---|
| frontend | 100m | 200m | 64Mi | 128Mi |
| checkoutservice | 100m | 200m | 64Mi | 128Mi |
| cartservice | 200m | 300m | 64Mi | 128Mi |
| recommendationservice | 100m | 200m | 220Mi | 450Mi |
| adservice | 200m | 300m | 180Mi | 300Mi |
| loadgenerator | 300m | 500m | 256Mi | 512Mi |
| redis-cart | 70m | 125m | 200Mi | 256Mi |

---

## 🧠 Key DevOps Learnings

- Designing **multi-service Kubernetes manifests** for a distributed system
- Configuring **gRPC health checks** instead of HTTP for non-REST services
- Implementing **pod security contexts** to follow the principle of least privilege
- Setting up **Jenkins pipeline with Kubernetes credentials** for secure automated deployments
- Understanding **service discovery** via Kubernetes DNS (`servicename:port`)
- Managing **resource quotas** to ensure cluster stability

---

## 👨‍💻 Author

**Sai Surya Teja**
DevOps Engineer | AWS • Kubernetes • Jenkins • Docker • Terraform | CI/CD Automation

[![GitHub](https://img.shields.io/badge/GitHub-saisuryateja1234-181717?style=flat&logo=github)](https://github.com/saisuryateja1234)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=flat&logo=linkedin)](www.linkedin.com/in/suryadevopsengineer)

---
