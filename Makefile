SHELL := /bin/bash

# ============================================================================
# Define Settings

VERSION := 1.0
SERVICE_IMAGE := sales-api-amd64
APP := sales
NAMESPACE := sales-system
KIND := kindest/node:v1.28.0
KIND_CLUSTER := sales-starter-cluster
DEPLOYMENT := sales-pod

# ============================================================================
# Building containers

all: sales-api

sales-api:
	docker build \
		-f configs/docker/dockerfile.sales-api \
		-t $(SERVICE_IMAGE):$(VERSION) \
		--build-arg BUILD_REF=$(VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.

# ============================================================================
# Running the app

run:
	go run main.go

# ==============================================================================
# Modules support

tidy:
	go mod tidy
	go mod vendor

# ============================================================================
# Running from within k8s/kind

kind-up:
	kind create cluster \
		--image $(KIND) \
		--name $(KIND_CLUSTER) \
		--config configs/k8s/kind/kind-config.yaml
	kubectl config set-context --current --namespace=$(NAMESPACE)

kind-load:
	cd configs/k8s/kind/sales-pod; kustomize edit set image sales-api-image=$(SERVICE_IMAGE):$(VERSION)
	kind load docker-image $(SERVICE_IMAGE):$(VERSION) --name $(KIND_CLUSTER)

kind-apply:
	kustomize build configs/k8s/kind/sales-pod | kubectl apply -f -

kind-restart:
	kubectl rollout restart deployment $(DEPLOYMENT)

kind-update: all kind-load kind-restart

kind-update-apply: all kind-load kind-apply

kind-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide
	kubectl get pods -o wide --watch --all-namespaces

kind-status-sales:
	kubectl get pods -o wide --watch

kind-logs:
	kubectl logs -l app=$(APP) --all-containers=true -f --tail=100

kind-describe:
	kubectl describe pod -l app=$(APP)

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)
