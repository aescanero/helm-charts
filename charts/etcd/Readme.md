# etcd Helm Chart

A Helm chart for deploying a highly available etcd cluster on Kubernetes.

## Introduction

This Helm chart deploys a scalable etcd cluster using the etcd-node controller, which provides a management layer for etcd instances. The chart supports configurable replication, persistent storage, TLS encryption, and authentication.

## Prerequisites

- Kubernetes 1.16+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)
- Optional: cert-manager v1.0.0+ (if TLS with cert-manager is enabled)

## Installing the Chart

To install the chart with the release name `my-etcd`:

```bash
helm install my-etcd .
```

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-etcd` deployment:

```bash
helm delete my-etcd
```

## Configuration

The following table lists the configurable parameters of the etcd chart and their default values.

| Parameter                                 | Description                                                                                       | Default                              |
|-------------------------------------------|---------------------------------------------------------------------------------------------------|--------------------------------------|
| `nameOverride`                            | Override the name of the chart                                                                    | `""`                                 |
| `fullnameOverride`                        | Override the full name of the chart                                                               | `""`                                 |
| `image.repository`                        | etcd image repository                                                                             | `docker.io/aescanero/etcd-node:v0.0.1` |
| `image.tag`                               | etcd image tag                                                                                    | `v0.0.1`                             |
| `image.pullPolicy`                        | etcd image pull policy                                                                            | `IfNotPresent`                       |
| `replicas`                                | Number of etcd cluster members                                                                    | `3`                                  |
| `resources.requests.cpu`                  | CPU request per etcd pod                                                                          | `500m`                               |
| `resources.requests.memory`               | Memory request per etcd pod                                                                       | `512Mi`                              |
| `resources.limits.cpu`                    | CPU limit per etcd pod                                                                            | `1000m`                              |
| `resources.limits.memory`                 | Memory limit per etcd pod                                                                         | `1Gi`                                |
| `persistence.enabled`                     | Enable persistent storage for etcd data                                                           | `true`                               |
| `persistence.storageClass`                | StorageClass for PVCs                                                                             | `""`                                 |
| `persistence.size`                        | Size of PVCs                                                                                      | `10Gi`                               |
| `service.type`                            | Kubernetes Service type                                                                           | `ClusterIP`                          |
| `service.clientPort`                      | etcd client port                                                                                  | `2379`                               |
| `service.peerPort`                        | etcd peer port                                                                                    | `2380`                               |
| `tls.enabled`                             | Enable TLS for etcd                                                                               | `false`                              |
| `tls.certManager.enabled`                 | Use cert-manager to generate certificates                                                         | `false`                              |
| `tls.certManager.issuerRef.name`          | Name of the issuer to use for certificates                                                        | `""`                                 |
| `tls.certManager.issuerRef.kind`          | Kind of the issuer (e.g., ClusterIssuer, Issuer)                                                 | `ClusterIssuer`                      |
| `tls.certManager.dnsNames`                | DNS names to include in the certificate                                                           | `[]`                                 |
| `tls.existingSecrets.enabled`             | Use existing secrets for TLS                                                                      | `false`                              |
| `tls.existingSecrets.server.secretName`   | Name of the existing secret for server TLS                                                        | `""`                                 |
| `tls.existingSecrets.server.certFile`     | Certificate file name in the secret                                                               | `tls.crt`                            |
| `tls.existingSecrets.server.keyFile`      | Key file name in the secret                                                                       | `tls.key`                            |
| `tls.existingSecrets.server.caFile`       | CA file name in the secret                                                                        | `ca.crt`                             |
| `tls.existingSecrets.peer.secretName`     | Name of the existing secret for peer TLS                                                          | `""`                                 |
| `tls.existingSecrets.peer.certFile`       | Certificate file name in the peer secret                                                          | `tls.crt`                            |
| `tls.existingSecrets.peer.keyFile`        | Key file name in the peer secret                                                                  | `tls.key`                            |
| `tls.existingSecrets.peer.caFile`         | CA file name in the peer secret                                                                   | `ca.crt`                             |
| `configuration.initialClusterState`       | Initial cluster state                                                                             | `new`                                |
| `configuration.initialClusterToken`       | Initial cluster token                                                                             | `etcd-cluster-1`                     |
| `configuration.autoCompactionRetention`   | Auto compaction retention in hours                                                                | `1`                                  |
| `configuration.quotaBackendBytes`         | Backend quota size in bytes                                                                       | `8589934592`                         |
| `serviceAccount.create`                   | Create a service account                                                                          | `true`                               |
| `serviceAccount.name`                     | The name of the service account                                                                   | `""`                                 |
| `serviceAccount.annotations`              | Annotations for the service account                                                               | `{}`                                 |
| `auth.enabled`                            | Enable authentication                                                                             | `true`                               |
| `auth.rootPassword`                       | Password for the root user                                                                        | `root-password`                      |
| `auth.users`                              | List of additional users                                                                          | `[]`                                 |

## Deployment Examples

### Basic Deployment

```yaml
# values.yaml
replicas: 3
persistence:
  enabled: true
  size: 5Gi
```

### Enabling TLS with cert-manager

```yaml
# values.yaml
tls:
  enabled: true
  certManager:
    enabled: true
    issuerRef:
      name: letsencrypt-prod
      kind: ClusterIssuer
```

### Using Existing TLS Secrets

```yaml
# values.yaml
tls:
  enabled: true
  existingSecrets:
    enabled: true
    server:
      secretName: etcd-server-tls
      certFile: tls.crt
      keyFile: tls.key
      caFile: ca.crt
    peer:
      secretName: etcd-peer-tls
      certFile: tls.crt
      keyFile: tls.key
      caFile: ca.crt
```

### Configuring Authentication

```yaml
# values.yaml
auth:
  enabled: true
  rootPassword: "my-secure-password"
  users:
    - name: readonly
      password: "readonly-password"
      roles:
        - readonly
    - name: admin
      password: "admin-password"
      roles:
        - readwrite
```

## Persistence

The chart mounts a [Persistent Volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) for each etcd pod. The volume is created using dynamic volume provisioning. If you want to disable this functionality, you can change the `persistence.enabled` parameter to `false`.

## Using etcdctl with the Deployed Cluster

To use `etcdctl` to interact with your deployed etcd cluster:

```bash
# Get the etcd pods
kubectl get pods -l app.kubernetes.io/name=etcd

# Use etcdctl inside the pod
kubectl exec -it <etcd-pod-name> -- etcdctl member list
```

If authentication is enabled:

```bash
kubectl exec -it <etcd-pod-name> -- etcdctl --user root:<password> member list
```

If TLS is enabled:

```bash
kubectl exec -it <etcd-pod-name> -- etcdctl --cacert /etc/etcd/server-tls/ca.crt --cert /etc/etcd/server-tls/tls.crt --key /etc/etcd/server-tls/tls.key member list
```

## Health Monitoring

The etcd-node controller provides a health API endpoint for monitoring the cluster's health. This can be accessed at:

```
http://<pod-ip>:8080/health
```

## Backup and Restore

### Creating a Backup

```bash
kubectl exec -it <etcd-pod-name> -- etcdctl snapshot save /var/run/etcd/backup.db
kubectl cp <etcd-pod-name>:/var/run/etcd/backup.db ./backup.db
```

### Restoring from a Backup

1. Scale down the StatefulSet
2. Copy the backup to the persistent volumes
3. Restart with restore flags

## Scaling the Cluster

Scaling the etcd cluster requires careful planning:

1. For scaling up, simply increase the `replicas` value.
2. For scaling down, you'll need to:
   - Remove the member from the cluster using etcdctl
   - Scale down the StatefulSet

## Prometheus Monitoring

This chart provides integration with Prometheus to monitor your etcd cluster. When enabled, each etcd node exposes metrics in Prometheus format at the `/metrics` endpoint.

### Available Metrics

The main metrics exposed include:

- `etcd_node_up`: Indicates if the node is operational (1) or down (0)
- `etcd_node_process_running`: If the etcd process is running
- `etcd_node_socket_available`: If the etcd socket is available
- `etcd_node_socket_blocked`: If the socket is blocked (indicates issues)
- `etcd_node_data_valid`: If the database is valid
- `etcd_node_has_leader`: If the cluster has an elected leader
- `etcd_node_is_leader`: If this node is the leader
- `etcd_node_cluster_size`: Number of members in the cluster
- `etcd_node_database_size_bytes`: Size of the etcd database
- `etcd_node_operations_total`: Total number of operations by type
- `etcd_node_operation_errors_total`: Total number of operation errors by type
- `etcd_node_operation_duration_seconds`: Duration of operations
- `etcd_node_last_compaction_timestamp`: Last compaction time
- `etcd_node_compactions_total`: Total number of compactions

### Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `monitoring.enabled` | Enable Prometheus metrics | `true` |
| `monitoring.port` | Port to expose Prometheus metrics | `8080` |
| `monitoring.path` | Path for Prometheus metrics | `/metrics` |
| `monitoring.serviceMonitor.enabled` | Use ServiceMonitor for Prometheus Operator | `false` |
| `monitoring.serviceMonitor.interval` | Scraping interval | `15s` |
| `monitoring.serviceMonitor.labels` | Additional ServiceMonitor labels | `{}` |
| `monitoring.serviceMonitor.namespace` | ServiceMonitor namespace | Same as release |
| `healthCheck.enabled` | Enable health checking | `true` |
| `healthCheck.path` | Path for health check | `/health` |

### Prometheus Operator

If you're using the Prometheus Operator, you can enable the ServiceMonitor to automatically configure scraping:

```yaml
monitoring:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 10s
    # Additional labels if needed for your Prometheus to find this ServiceMonitor
    labels:
      release: prometheus
```

### Manual Prometheus Configuration

If you're not using the Prometheus Operator, you can configure Prometheus manually with a configuration like:

```yaml
scrape_configs:
  - job_name: 'etcd'
    kubernetes_sd_configs:
      - role: endpoints
        namespaces:
          names:
            - YOUR_NAMESPACE
    relabel_configs:
      - source_labels: [__meta_kubernetes_service_name]
        action: keep
        regex: YOUR_RELEASE_NAME-etcd-metrics
      - source_labels: [__meta_kubernetes_endpoint_port_name]
        action: keep
        regex: metrics
```

## License

This Helm Chart is licensed under the Apache License 2.0. See the LICENSE file for details.

## Author

Alejandro Escanero Blanco <aescanero@disasterproject.com>