all: init deploy

init:
	k3d cluster create argocd-p3 --wait
	kubectl create namespace argocd
	kubectl create namespace dev
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

deploy:
	kubectl apply -f ./manifests/argocd-application.yml

clean:
	kubectl delete -f ./manifests/argocd-application.yml --ignore-not-found=true
	kubectl delete namespace argocd
	kubectl delete namespace dev
	k3d cluster delete argocd-p3

re: clean all

port-forward-argocd:
	kubectl port-forward service/argocd-server -n argocd 8080:443

port-forward-playground:
	kubectl port-forward service/ykarabul-playground -n dev 8888:8888

argocd-credentials:
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

test-playground:
	curl http://localhost:8888/

.PHONY: init deploy clean re port-forward-argocd port-forward-playground test-playground