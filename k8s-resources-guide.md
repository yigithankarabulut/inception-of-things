# Kubernetes Resources Guide

## **Basic Concepts**

There are various resource types for managing different workloads and services in Kubernetes. Each is designed for different purposes.

---

## **WORKLOAD RESOURCES**

### 1. 📦 **Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
```

### 2. 🗄️ **StatefulSet**
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
```

### 3. ⚡ **Job**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: backup-job
spec:
  template:
    spec:
      containers:
      - name: backup
        image: busybox
        command: ["sh", "-c", "echo 'Backup completed'"]
      restartPolicy: Never
```

### 4. ⏰ **CronJob**
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: daily-report
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: report
            image: busybox
            command: ["sh", "-c", "echo 'Daily report generated'"]
          restartPolicy: OnFailure
```

### 5. 🖥️ **DaemonSet**
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-collector
spec:
  selector:
    matchLabels:
      name: log-collector
  template:
    metadata:
      labels:
        name: log-collector
    spec:
      containers:
      - name: fluentd
        image: fluentd:latest
```

---

## **SERVICE RESOURCES**

### 6. 🌐 **Service**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: ClusterIP
```

### 7. 🌍 **Ingress**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
```

### 8. 🔗 **Endpoints**
```yaml
apiVersion: v1
kind: Endpoints
metadata:
  name: external-service
subsets:
- addresses:
  - ip: 192.168.1.100
  ports:
  - port: 80
    name: http
```

### 9. 🔗 **EndpointSlice**
```yaml
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: nginx-endpoints
  labels:
    kubernetes.io/service-name: nginx-service
addressType: IPv4
ports:
- name: http
  port: 80
  protocol: TCP
endpoints:
- addresses:
  - "10.244.1.1"
  - "10.244.1.2"
```

---

## **CONFIGURATION RESOURCES**

### 10. ⚙️ **ConfigMap**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "mysql://localhost:3306/mydb"
  debug: "true"
  log_level: "info"
```

### 11. 🔐 **Secret**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded
  password: cGFzc3dvcmQ=  # base64 encoded
```

### 12. 🔑 **ServiceAccount**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-service-account
automountServiceAccountToken: true
```

---

## **STORAGE RESOURCES**

### 13. 💾 **PersistentVolume (PV)**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  hostPath:
    path: /data/mysql
```

### 14. 💾 **PersistentVolumeClaim (PVC)**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: local-storage
```

### 15. 💾 **StorageClass**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

---

## **SECURITY RESOURCES**

### 16. 🔑 **Role**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

### 17. 🔑 **RoleBinding**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

### 18. 🔑 **ClusterRole**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
```

### 19. 🔑 **ClusterRoleBinding**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-secrets
subjects:
- kind: User
  name: admin
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

---

## **NETWORK RESOURCES**

### 20. 🌐 **NetworkPolicy**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### 21. 🌐 **IngressClass**
```yaml
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: nginx
spec:
  controller: nginx.org/ingress-controller
```

---

## **MONITORING RESOURCES**

### 22. 📊 **HorizontalPodAutoscaler (HPA)**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

### 23. 📊 **PodDisruptionBudget**
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: nginx-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: nginx
```

## 📊 **COMPARISON TABLE**

| Category | Resource | Usage Area | Example |
|----------|--------|----------------|-------|
| **Workload** | Deployment | Stateless apps | Web apps, API |
| **Workload** | StatefulSet | Stateful apps | Databases |
| **Workload** | Job | One-time tasks | Backup, analysis |
| **Workload** | CronJob | Scheduled tasks | Daily reports |
| **Workload** | DaemonSet | Node services | Log collectors |
| **Service** | Service | Internal networking | Load balancing |
| **Service** | Ingress | External access | HTTP routing |
| **Service** | Endpoints | Service endpoints | External services |
| **Service** | EndpointSlice | Modern endpoints | Service discovery |
| **Config** | ConfigMap | Configuration | App settings |
| **Config** | Secret | Sensitive data | Passwords, keys |
| **Config** | ServiceAccount | Identity | Pod identity |
| **Storage** | PV | Storage volumes | Disk space |
| **Storage** | PVC | Storage requests | Volume claims |
| **Storage** | StorageClass | Storage provisioning | Volume management |
| **Security** | Role | Permissions | Access control |
| **Security** | RoleBinding | Permission assignment | User access |
| **Security** | ClusterRole | Cluster permissions | Cluster access |
| **Security** | ClusterRoleBinding | Cluster assignment | Cluster access |
| **Network** | NetworkPolicy | Network security | Traffic rules |
| **Network** | IngressClass | Ingress config | Controller setup |
| **Monitoring** | HPA | Auto scaling | CPU/Memory scaling |
| **Monitoring** | PodDisruptionBudget | Availability | Disruption protection |

## 💡 **WHEN TO USE WHAT?**

### 📦 **Application Running:**
- **Deployment** → Web applications
- **StatefulSet** → Databases
- **Job** → One-time tasks
- **CronJob** → Scheduled tasks
- **DaemonSet** → Node services

### 🌐 **Service Management:**
- **Service** → Internal load balancing
- **Ingress** → External HTTP routing
- **Endpoints** → External service endpoints
- **EndpointSlice** → Modern service endpoints

### 🌐 **Network Security:**
- **NetworkPolicy** → Network security
- **IngressClass** → Ingress controller configuration

### ⚙️ **Configuration:**
- **ConfigMap** → Application settings
- **Secret** → Sensitive data
- **ServiceAccount** → Pod identity

### 💾 **Storage:**
- **PV** → Storage volumes
- **PVC** → Storage requests
- **StorageClass** → Storage provisioning

### 🔑 **Security:**
- **Role** → Namespace permissions
- **ClusterRole** → Cluster permissions
- **RoleBinding** → Permission assignment
- **ClusterRoleBinding** → Cluster-wide permission assignment

### 📊 **Monitoring & Scaling:**
- **HorizontalPodAutoscaler** → Auto scaling based on metrics
- **PodDisruptionBudget** → Availability during disruptions

---

## 🚀 **PRACTICAL EXAMPLES**

### Full Stack Application:
```bash
# 1. Create ConfigMap
kubectl create configmap app-config --from-literal=database_url=mysql://localhost:3306

# 2. Create Secret
kubectl create secret generic app-secret --from-literal=password=secret123

# 3. Create Deployment
kubectl create deployment web-app --image=nginx

# 4. Create Service
kubectl expose deployment web-app --port=80 --type=ClusterIP

# 5. Create Ingress
kubectl create ingress web-ingress --rule="example.com/*=web-app:80"
```

### Monitoring and Scaling:
```bash
# Create HPA
kubectl autoscale deployment web-app --cpu-percent=50 --min=1 --max=10

# Create PDB
kubectl create pdb web-app-pdb --selector=app=web-app --min-available=1
```

---

## 💡 **SUMMARY**

There are 20+ different resource types in Kubernetes:

- **Workload** → Run applications
- **Service** → Network connections
- **Config** → Configuration
- **Storage** → Storage
- **Security** → Security
- **Network** → Network security
- **Monitoring** → Monitoring and scaling