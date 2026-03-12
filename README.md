# Restauranty

A restaurant management platform built with a **microservices architecture**: 3 Node.js/Express backends + a React frontend, unified behind HAProxy path-based routing.

## Architecture

```
                         ┌────────────────────────┐
                         │   HAProxy / Ingress    │
    Browser ───────────► │       (port 80)        │
                         └───────────┬────────────┘
                                     │
            ┌────────────────────────┼─────────────────────────┐
            │                        │                         │
       /api/auth/*             /api/items/*             /api/discounts/*
            │                        │                         │
   ┌────────▼────────┐     ┌─────────▼─────────┐    ┌─────────▼──────────┐
   │  Auth Service   │     │  Items Service    │    │ Discounts Service  │
   │   (port 3001)   │     │   (port 3003)     │    │   (port 3002)      │
   └────────┬────────┘     └─────────┬─────────┘    └──────────┬─────────┘
            │                        │                         │
            └────────────────────────┼─────────────────────────┘
                                     │
                              ┌──────▼──────┐
                              │   MongoDB   │
                              │ (port 27017)│
                              └─────────────┘
```

## Microservices

| Service | Port | Path | Responsibilities |
|---------|------|------|-----------------|
| **Auth** | 3001 | `/api/auth/*` | User signup, login, JWT authentication |
| **Discounts** | 3002 | `/api/discounts/*` | Coupon and campaign management |
| **Items** | 3003 | `/api/items/*` | Menu items, dietary categories, orders |
| **Frontend** | 3000 | `/` | React SPA (admin dashboard) |

## Quick Start

### 1. Start MongoDB

```bash
docker run -d \
  --name my-mongo \
  -p 27017:27017 \
  -v mongo-data:/data/db \
  mongo:latest
```

### 2. Start each microservice

```bash
# Terminal 1 - Auth
cd backend/auth && npm install && npm start

# Terminal 2 - Discounts
cd backend/discounts && npm install && npm start

# Terminal 3 - Items
cd backend/items && npm install && npm start

# Terminal 4 - Frontend
cd client && npm install && npm start
```

### 3. Start HAProxy

```bash
haproxy -f haproxy.cfg
```

Access the app at **http://localhost/**

## Environment Variables

Each microservice uses the same set of environment variables (see `.env.example` in each service folder):

| Variable | Description | Example |
|----------|-------------|---------|
| `SECRET` | JWT signing key | `MySecret1!` |
| `MONGODB_URI` | MongoDB connection string | `mongodb://127.0.0.1:27017/restauranty` |
| `CLOUD_NAME` | Cloudinary cloud name | _(ask instructor)_ |
| `CLOUD_API_KEY` | Cloudinary API key | _(ask instructor)_ |
| `CLOUD_API_SECRET` | Cloudinary API secret | _(ask instructor)_ |
| `PORT` | Service port | `3001` / `3002` / `3003` |

For the frontend, use the `REACT_APP_` prefix: `REACT_APP_API_URL=http://localhost:80`

## Tech Stack

- **Frontend**: React 18, React Router 6, Tailwind CSS, Axios, React Icons
- **Backend**: Express, Mongoose, JWT (jsonwebtoken + express-jwt), bcryptjs
- **Image Storage**: Cloudinary (via multer-storage-cloudinary)
- **Monitoring**: Prometheus metrics (`/metrics` endpoint on each backend service)
- **Routing**: HAProxy (local) / Kubernetes Ingress (production)
- **Database**: MongoDB

## Infrastructure as Code (Terraform)

To improve reproducibility and maintainability of the cloud infrastructure, Terraform was introduced as an Infrastructure as Code (IaC) tool.

The Restauranty platform runs on **Azure Kubernetes Service (AKS)** and uses additional Azure services such as **Azure Key Vault** for secret management. Initially, these resources were provisioned manually using the Azure CLI during development. Terraform was later introduced to manage the existing infrastructure declaratively.

### Managed Resources

The Terraform configuration currently manages the following Azure resources:

- Azure Resource Group for AKS
- Azure Kubernetes Service (AKS) cluster
- Azure Resource Group for shared services
- Azure Key Vault

Terraform files are located in the `/terraform` directory.

```
terraform/
│
├ providers.tf
├ variables.tf
├ resource_groups.tf
├ aks.tf
├ keyvault.tf
├ outputs.tf
└ .gitignore
```

### Importing Existing Infrastructure

Because the infrastructure already existed before Terraform was introduced, the resources were imported into the Terraform state using the `terraform import` command.

Example imports:

```bash
terraform import azurerm_resource_group.aks_rg \
/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/restauranty-lily-bel-rg

terraform import azurerm_kubernetes_cluster.aks \
/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/restauranty-lily-bel-rg/providers/Microsoft.ContainerService/managedClusters/restauranty-lily-aks

terraform import azurerm_resource_group.kv_rg \
/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/restauranty-lily-rg

terraform import azurerm_key_vault.kv \
/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/restauranty-lily-rg/providers/Microsoft.KeyVault/vaults/RestaurantyLily
```

After importing the resources, the Terraform configuration was iteratively aligned with the existing infrastructure using:

```bash
terraform plan
terraform state show <resource>
```

This process ensured that Terraform accurately represents the deployed infrastructure.

### Running Terraform

Initialize Terraform:

```bash
terraform init
```

Validate the configuration:

```bash
terraform validate
```

Preview infrastructure changes:

```bash
terraform plan
```

### Handling Existing Infrastructure Drift

Since the AKS cluster was originally provisioned outside of Terraform, a small provider-managed drift may still appear during `terraform plan`. Certain AKS configuration fields are controlled internally by Azure and may not perfectly match the Terraform configuration.

To prevent unnecessary updates, Terraform lifecycle rules are used where appropriate.

### Terraform State

Terraform state files are **not committed to the repository**.

The following files are ignored:

```
.terraform/
terraform.tfstate
terraform.tfstate.backup
```

This prevents sensitive infrastructure metadata from being exposed in the repository.

### Benefits

Using Terraform provides several advantages:

- Infrastructure becomes **version controlled**
- Infrastructure changes can be **reviewed before deployment**
- The environment can be **recreated reliably**
- Configuration drift can be detected using `terraform plan`
- Infrastructure configuration is **documented as code**


## Monitoring and Observability

This project includes a monitoring setup using **Prometheus** and **Grafana** to collect and visualize metrics from the Restauranty microservices running in Kubernetes.

The monitoring stack provides insights into:

- HTTP request volume
- Error rates
- API usage
- Request latency
- Service health

Each service exposes a `/metrics` endpoint which is scraped by Prometheus.

---

## Metrics Collection

Metrics are implemented using the **prom-client** library for Node.js.

### HTTP Request Metrics

The application tracks HTTP requests using the following metrics:

- `http_requests_total`
- `http_requests_overall_total`

These metrics include labels such as:

- `method`
- `route`
- `statusCode`

Example:

```
http_requests_total{method="GET",route="/api/items/dietary",statusCode="200"} 12
```

These metrics allow monitoring of request rates, traffic distribution, and status codes.

---

### HTTP Request Latency

Request latency is measured using a **Prometheus histogram**:

```
http_request_duration_seconds
```

This metric allows calculation of:

- Average request latency
- p50 latency (median)
- p95 latency (slow requests)

Histogram buckets:

```
0.005
0.01
0.025
0.05
0.1
0.25
0.5
1
2
5 seconds
```

These buckets allow Prometheus to calculate latency percentiles.

---

### Business Metrics

The application also exposes custom metrics for domain data:

- `items_total`
- `dietaries_total`

These gauges represent the number of items and dietary entries stored in the database and are updated periodically.

---

## Prometheus

Prometheus scrapes metrics from each service via the `/metrics` endpoint.

Example endpoint:

```
http://<service>:<port>/metrics
```

Prometheus stores the collected metrics as time-series data which can be queried using **PromQL**.

Example query:

```
rate(http_requests_total[5m])
```

Example latency query:

```
histogram_quantile(
  0.95,
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
)
```

---

## Grafana Dashboards

Metrics are visualized using **Grafana dashboards**.

The dashboard includes panels for:

### Request Monitoring

- Total request rate
- Request volume by service
- Requests per second by service
- Requests by route

### Error Monitoring

- 400 error rate
- 500 error rate
- 500 errors by service

### Latency Monitoring

- Average request latency
- p50 latency
- p95 latency

These panels help identify slow endpoints, traffic patterns, and system issues.

---

## Viewing Metrics

Metrics can be accessed in multiple ways.

### Directly via the Metrics Endpoint

```
GET /metrics
```

Example:

```
http://localhost:3000/metrics
```

---

### Using Prometheus

Run queries such as:

```
rate(http_requests_total[5m])
```

or

```
histogram_quantile(
  0.95,
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
)
```

---

### Using Grafana

Grafana provides dashboards that visualize:

- service traffic
- request latency
- error rates
- endpoint usage

These dashboards allow quick analysis of system performance and behavior.

---

## Viewing Logs

Logs for the services can be viewed using Kubernetes.

### View logs for a deployment

```
kubectl logs deployment/items-deployment -n restauranty-lily
```

### View logs for a specific pod

```
kubectl get pods -n restauranty-lily
kubectl logs <pod-name> -n restauranty-lily
```

### Follow logs in real time

```
kubectl logs -f deployment/items-deployment -n restauranty-lily
```

This allows developers to inspect runtime behavior and debug issues.

---

## Summary

The observability stack combines:

- **Prometheus** for metric collection
- **Grafana** for visualization
- **custom application metrics**
- **Kubernetes logs**

Together these tools provide full visibility into the health, performance, and usage of the Restauranty microservices.

