GITLAB_DOMAIN=ykarabul.com
GITLAB_PORT=8080
ARGOCD_PORT=8081
PLAYGROUND_PORT=8888

all: init install-gitlab 

init:
	k3d cluster create bonus --wait
	kubectl create namespace argocd
	kubectl create namespace dev
	kubectl create namespace gitlab

deploy-argocd:
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	kubectl apply -n argocd -f ./manifests/argocd-application.yml

clean:
	kubectl delete -f ./manifests/argocd-application.yml --ignore-not-found=true
	kubectl delete namespace argocd
	kubectl delete namespace dev
	kubectl delete namespace gitlab
	k3d cluster delete bonus
	@echo "Cleaned up all resources"

install-helm:
	@echo "Installing Helm..."
	curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
	chmod 700 get_helm.sh
	./get_helm.sh
	rm get_helm.sh
	@echo "Helm installed successfully"

install-gitlab:
	@echo "Installing GitLab (minimal configuration)..."
	kubectl config set-context --current --namespace=gitlab
	helm repo add gitlab https://charts.gitlab.io/
	helm repo update
	helm install gitlab gitlab/gitlab \
		-f ./manifests/minimum-values.yml \
		--version 7.7.0
	@echo "GitLab installation started"


wait-gitlab:
	@echo "Waiting for GitLab to be ready..."
	grep -q $(GITLAB_DOMAIN) /etc/hosts || echo "127.0.0.1 $(GITLAB_DOMAIN)" >> /etc/hosts
	kubectl wait --for=condition=ready pod -l app=webservice -n gitlab --timeout=1200s
	@echo "GitLab is ready!"

migrate-repo:
	@echo "Migrating repository to GitLab..."
	chmod +x ./scripts/gitlab.sh
	./scripts/gitlab.sh

re: clean all

port-forward-gitlab:
	@echo "Port forwarding GitLab to $(GITLAB_PORT)..."
	kubectl port-forward service/gitlab-webservice-default -n gitlab $(GITLAB_PORT):8080

port-forward-argocd:
	@echo "Port forwarding ArgoCD to $(ARGOCD_PORT)..."
	kubectl port-forward service/argocd-server -n argocd $(ARGOCD_PORT):443

port-forward-playground:
	@echo "Port forwarding Playground to $(PLAYGROUND_PORT)..."
	kubectl port-forward service/ykarabul-playground -n dev $(PLAYGROUND_PORT):8888

argocd-credentials:
	@echo "ArgoCD Admin Password:"
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

gitlab-credentials:
	@echo "GitLab Root Password:"
	kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath='{.data.password}' | base64 --decode && echo

test-playground:
	@echo "Testing playground application..."
	curl http://localhost:$(PLAYGROUND_PORT)/

test-gitlab:
	@echo "Testing GitLab..."
	curl http://$(GITLAB_DOMAIN):$(GITLAB_PORT)/

status:
	@echo "=== Cluster Status ==="
	kubectl get pods -n argocd
	kubectl get pods -n gitlab
	kubectl get pods -n dev
	@echo "=== Services ==="
	kubectl get svc -n argocd
	kubectl get svc -n gitlab
	kubectl get svc -n dev

.PHONY: all init deploy clean install-helm install-gitlab wait-gitlab migrate-repo re port-forward-gitlab port-forward-argocd port-forward-playground argocd-credentials gitlab-credentials test-playground test-gitlab status re-install-gitlab deploy-argocd