# 🚀 Kubectl Commands Guide

## 🔍 **GET**
```bash
# Show basic resources
kubectl get pods,svc,deploy,ingress -n <namespace>

# In all namespaces
kubectl get all --all-namespaces

# Detailed information
kubectl get pods -o wide
kubectl get pods -o yaml
kubectl get pods -o json

# Filter by labels
kubectl get pods -l app=myapp
```

## 📋 **DESCRIBE**
```bash
# Pod details
kubectl describe pod <pod-name>

# Service details
kubectl describe svc <service-name>

# All resources
kubectl describe all -n <namespace>
```

## 🏃 **RUN/EXEC**
```bash
# Run command in pod
kubectl exec -it <pod-name> -- /bin/bash
kubectl exec -it <pod-name> -- sh

# Create temporary pod
kubectl run temp-pod --image=busybox --rm -it -- /bin/sh
```

## 📝 **APPLY/DELETE**
```bash
# Apply from file
kubectl apply -f manifest.yml
kubectl apply -f manifests/

# Delete
kubectl delete -f manifest.yml
kubectl delete pod <pod-name>
kubectl delete all --all -n <namespace>
```

## 🔄 **RESTART**
```bash
# Restart Deployment
kubectl rollout restart deployment/<name>

# Restart StatefulSet
kubectl rollout restart statefulset/<name>

# Delete pods (automatically recreated)
kubectl delete pods -l app=myapp
```

## 📊 **LOGS**
```bash
# Pod logs
kubectl logs <pod-name>

# Live log tracking
kubectl logs -f <pod-name>

# Previous container logs
kubectl logs <pod-name> --previous
```

## 🌐 **PORT FORWARD**
```bash
# Port forwarding
kubectl port-forward svc/<service-name> 8080:80
kubectl port-forward pod/<pod-name> 8080:8080
```

## 🏷️ **LABEL**
```bash
# Add label
kubectl label pod <pod-name> app=myapp

# Delete label
kubectl label pod <pod-name> app-

# Show labels
kubectl get pods --show-labels
```

## 🔧 **EDIT**
```bash
# Edit resource
kubectl edit pod <pod-name>
kubectl edit svc <service-name>

# Edit ConfigMap
kubectl edit configmap <config-name>
```

## �� **COPY**
```bash
# Copy file
kubectl cp <pod-name>:/path/to/file ./local-file
kubectl cp ./local-file <pod-name>:/path/to/file
```

## 🔍 **SEARCH**
```bash
# Search resource
kubectl get pods | grep <pattern>
kubectl get all | grep <pattern>

# List API resources
kubectl api-resources
```

## ⚡ **QUICK COMMANDS**
```bash
# Short names
kubectl get po    # pods
kubectl get svc   # services  
kubectl get deploy # deployments
kubectl get ing   # ingress
kubectl get cm    # configmaps
kubectl get sec   # secrets
kubectl get ns    # namespaces
kubectl get no    # nodes
```

## 🎯 **MOST USED COMBINATIONS**
```bash
# Quick status check
kubectl get all -n <namespace>

# Detect pod problems
kubectl get pods -o wide && kubectl describe pod <problematic-pod>

# Log + Port forward
kubectl logs -f <pod-name> & kubectl port-forward svc/<svc-name> 8080:80

# Clean up
kubectl delete all --all -n <namespace>
```

## 🌐 **INGRESS COMMANDS**
```bash
# Show Ingresses
kubectl get ingress --all-namespaces
kubectl get ingress -n dev

# Ingress details
kubectl describe ingress <ingress-name> -n dev

# Ingress classes
kubectl get ingressclass

# Ingress controller
kubectl get pods -n kube-system | grep -E "(ingress|traefik)"
```

## 🔍 **ENDPOINTS & ENDPOINTSLICE**
```bash
# Show Endpoints
kubectl get endpoints --all-namespaces
kubectl get endpoints -n dev

# Show EndpointSlices
kubectl get endpointslice --all-namespaces
kubectl get endpointslice -n dev

# Show all resource types
kubectl get all,endpoints,endpointslice,configmap,secrets -n dev
```

## 💡 **RULES TO REMEMBER**
- `get` = Show
- `describe` = Detailed information
- `logs` = Show logs
- `exec` = Enter
- `apply` = Apply
- `delete` = Delete
- `edit` = Edit
- `port-forward` = Port forwarding

## �� **MAKEFILE EXAMPLES**
```makefile
# Basic commands
show-all:
	kubectl get all,endpoints,endpointslice,configmap,secrets -n dev

show-logs:
	kubectl logs -f deployment/$(APP_NAME) -n dev

port-forward:
	kubectl port-forward svc/$(SVC_NAME) $(LOCAL_PORT):$(SVC_PORT) -n dev

restart-app:
	kubectl rollout restart deployment/$(APP_NAME) -n dev

clean-namespace:
	kubectl delete all --all -n dev
```

---
**💡 Hint:** This commands covers 90% of kubectl! 🚀