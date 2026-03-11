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
