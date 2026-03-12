# Security Overview

This document describes the security architecture and practices used in the Restauranty DevOps project.

The application consists of multiple Node.js microservices deployed on Azure Kubernetes Service (AKS) and exposed through a single Ingress endpoint.

---

# 1. Network Security

The application uses a **single public entry point** via the Kubernetes Ingress controller.

All external traffic flows through the following path:

Internet → AKS Ingress → Microservices

Only the Ingress controller is publicly accessible.  
All backend services communicate internally inside the Kubernetes cluster.

This design reduces the attack surface and ensures that internal services are not directly exposed to the public internet.

Azure automatically provisions the following network components for the AKS cluster:

- Virtual Network (VNet)
- Network Security Groups (NSGs)
- Azure Load Balancer

These components provide additional network isolation and traffic control.

---

# 2. Authentication and Authorization

Authentication is handled by the **Auth microservice**.

Responsibilities of the auth service:

- User authentication
- JWT token generation
- Token-based authorization

Authentication workflow:

1. A user logs in via the Auth service.
2. The service returns a signed **JWT token**.
3. The client includes the token in subsequent requests.
4. Other microservices validate the token using middleware.

This ensures that only authenticated users can access protected endpoints across the platform.

---

# 3. Secret Management

Sensitive credentials are **never committed to the Git repository**.

Secrets are managed using:

- Kubernetes Secrets
- Azure Key Vault

Examples of secrets used by the application:

- MongoDB connection string
- JWT signing secret
- Cloudinary API credentials

Secrets are injected into containers as environment variables via Kubernetes.

Example environment variables:

CLOUD_API_KEY  
CLOUD_API_SECRET  
MONGODB_URI  
SECRET  

For infrastructure-level secrets, Azure Key Vault is used as a secure storage mechanism.

Terraform configuration files reference variables, while actual secret values are excluded from version control via `.gitignore` and `terraform.tfvars`.

---

# 4. Data Security

## Encryption in Transit

All traffic between the client and the cluster flows through the Kubernetes Ingress controller.

In production environments, TLS/HTTPS can be enabled using:

- NGINX Ingress TLS configuration
- Azure-managed certificates
- Let's Encrypt via cert-manager

For the purposes of this educational project, communication occurs over HTTP for simplicity.

## Encryption at Rest

Azure provides automatic encryption at rest for:

- Managed disks used by AKS nodes
- Persistent volumes
- Azure Key Vault stored secrets

MongoDB data stored on Azure disks is therefore encrypted at the infrastructure level by Azure.

---

# 5. Container Security

Each service runs inside its own container.

Isolation is provided through:

- Docker container boundaries
- Kubernetes pod isolation
- Kubernetes namespaces

Containers are built through the CI/CD pipeline and stored in a container registry before deployment.

This ensures that deployments use versioned, immutable container images.

---

# 6. Logging and Monitoring

Application logs follow container best practices and are written to **stdout**.

Kubernetes automatically captures container logs.

Logs can be accessed using:

kubectl logs <pod-name>

Monitoring is implemented using:

- **Prometheus** for metrics collection
- **Grafana** for visualization

The backend microservices expose a `/metrics` endpoint which Prometheus scrapes periodically.

Collected metrics include:

- HTTP request counts
- Response times
- Error rates

These metrics are visualized through Grafana dashboards.

---

# 7. Infrastructure Security

Infrastructure is managed using **Terraform Infrastructure as Code**.

Managed resources include:

- Azure Resource Groups
- Azure Kubernetes Service cluster
- Azure Key Vault

Infrastructure definitions are stored in the repository.

Sensitive configuration values are excluded from version control using `.gitignore` and `terraform.tfvars`.

Terraform state files are also excluded from Git.

---

# 8. Compliance Considerations

This project is a learning environment and not intended for production use.

However, the architecture follows best practices aligned with common compliance frameworks such as:

- GDPR
- SOC 2
- ISO 27001

Security practices demonstrated in this project include:

- secret management
- authentication and access control
- encrypted infrastructure
- centralized monitoring

No real user data or personal data is stored in the system.

---

# 9. Future Security Improvements

Possible improvements for a production deployment include:

- Enabling TLS/HTTPS on the Ingress controller
- Integrating Azure Monitor for centralized log aggregation
- Implementing Kubernetes NetworkPolicies
- Adding container vulnerability scanning
- Enabling Azure Defender for Kubernetes
- Implementing role-based access control for developers and operators

---

# Summary

The Restauranty platform applies multiple layers of security including:

- network isolation
- centralized authentication
- secure secret management
- container isolation
- monitoring and observability

While simplified for educational purposes, the architecture reflects common DevOps security patterns used in real-world cloud-native systems.
