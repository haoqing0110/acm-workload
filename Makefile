SHELL :=/bin/bash
MANAGED_CLUSTER_NAME ?= cluster1
RESOURCE_COUNT ?= 10
KUBECTL ?= oc

# Image URL to use all building/pushing image targets
IMAGE_REGISTRY ?= quay.io/haoqing
IMAGE_TAG ?= latest

SED_CMD:=sed
ifeq ($(GOHOSTOS),darwin)
	ifeq ($(GOHOSTARCH),amd64)
		SED_CMD:=gsed
	endif
endif

test: test-klusterlet-agent test-work-mgr test-managed-service-account test-application test-obs-search test-policy

test-failure: test-klusterlet-agent-failure test-work-mgr-failure test-application-failure test-obs-search-failure

test-klusterlet-agent:
	cd klusterlet-agent && ./run.sh apply resource.yaml $(RESOURCE_COUNT) $(MANAGED_CLUSTER_NAME)

test-klusterlet-agent-failure:
	cd klusterlet-agent && ./run.sh apply resource-failure.yaml $(RESOURCE_COUNT) $(MANAGED_CLUSTER_NAME)

test-work-mgr:
	cd work-manager && ./run.sh apply resource.yaml $(RESOURCE_COUNT) $(MANAGED_CLUSTER_NAME)

test-work-mgr-failure:
	cd work-manager && ./run.sh apply resource-failure.yaml $(RESOURCE_COUNT) $(MANAGED_CLUSTER_NAME)

test-managed-service-account:
	cd managed-service-account && \
	./run.sh apply resource.yaml $(RESOURCE_COUNT) $(MANAGED_CLUSTER_NAME)

test-application:
	cd application && ./run.sh apply healthy-app-helloworld.yaml $(RESOURCE_COUNT) $(MANAGED_CLUSTER_NAME)

test-application-failure:
	cd application && ./run.sh apply unhealthy-app-nginx.yaml $(RESOURCE_COUNT) $(MANAGED_CLUSTER_NAME)

test-obs-search:
	cd klusterlet-agent && ./run.sh apply resource.yaml 100 $(MANAGED_CLUSTER_NAME)

test-obs-search-failure:
	cd klusterlet-agent && ./run.sh apply resource-failure.yaml 100 $(MANAGED_CLUSTER_NAME)

test-policy:
	cd policy && ./run.sh apply resource.yaml $(RESOURCE_COUNT) $(MANAGED_CLUSTER_NAME)

clean-klusterlet-agent:
	cd klusterlet-agent && \
	./run.sh delete resource.yaml $(RESOURCE_COUNT) $(MANAGED_CLUSTER_NAME) || true && \
	./run.sh delete resource-failure.yaml $(RESOURCE_COUNT) $(MANAGED_CLUSTER_NAME) || true

clean-work-mgr:
	cd work-manager && \
	./run.sh delete resource.yaml $(RESOURCE_COUNT) $(MANAGED_CLUSTER_NAME) || true && \
	./run.sh delete resource-failure.yaml $(RESOURCE_COUNT) $(MANAGED_CLUSTER_NAME) || true

clean-managed-service-account:
	cd managed-service-account && \
	./run.sh delete resource.yaml $(RESOURCE_COUNT) $(MANAGED_CLUSTER_NAME) || true

clean-application:
	cd application && \
	./run.sh delete healthy-app-helloworld.yaml $(RESOURCE_COUNT) $(MANAGED_CLUSTER_NAME) || true && \
	./run.sh delete unhealthy-app-nginx.yaml $(RESOURCE_COUNT) $(MANAGED_CLUSTER_NAME) || true 

clean-obs-search:
	cd klusterlet-agent && ./run.sh delete resource.yaml 100 $(MANAGED_CLUSTER_NAME) || true

clean-policy:
	cd policy && ./run.sh delete resource.yaml $(RESOURCE_COUNT) $(MANAGED_CLUSTER_NAME) || true

clean-all: clean-klusterlet-agent clean-work-mgr clean-managed-service-account clean-application clean-obs-search clean-policy

enable-app:
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"applicationManager":{"enabled": true}}}' --type=merge

disable-app:
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"applicationManager":{"enabled": false}}}' --type=merge

enable-policy:
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"policyController":{"enabled": true}}}' --type=merge
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"iamPolicyController":{"enabled": false}}}' --type=merge
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"certPolicyController":{"enabled": false}}}' --type=merge

disable-policy:
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"policyController":{"enabled": false}}}' --type=merge
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"iamPolicyController":{"enabled": false}}}' --type=merge
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"certPolicyController":{"enabled": false}}}' --type=merge

enable-search:
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"searchCollector":{"enabled": true}}}' --type=merge

disable-search:
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"searchCollector":{"enabled": false}}}' --type=merge

enable-cluster-proxy:
	${KUBECTL} patch multiclusterengine multiclusterengine -p '{"spec":{"overrides":{"components":[{"enabled":true,"name":"cluster-proxy-addon"}]}}}' --type=merge

disable-cluster-proxy:
	${KUBECTL} patch multiclusterengine multiclusterengine -p '{"spec":{"overrides":{"components":[{"enabled":false,"name":"cluster-proxy-addon"}]}}}' --type=merge

enable-obs:
	./hack/addons/enable-obs.sh $(MANAGED_CLUSTER_NAME)

enable-obs-from-scratch: prepare-thanos-obj-storage-yaml enable-obs remove-thanos-obj-storage-yaml

prepare-thanos-obj-storage-yaml:
	$(call check_defined, AWS_BUCKET_NAME, AWS_BUCKET_NAME for obs is not defined)
	$(call check_defined, AWS_ACCESS_KEY, AWS_ACCESS_KEY for obs is not defined)
	$(call check_defined, AWS_SECRET_KEY, AWS_SECRET_KEY for obs is not defined)
	cp hack/addons/thanos-object-storage.yaml.sample hack/addons/thanos-object-storage.yaml
	$(SED_CMD) -i -e "s,<bucket-name>,$(AWS_BUCKET_NAME)," \
	-e "s,<access_key>,$(AWS_ACCESS_KEY)," \
	-e "s,<secret_key>,$(AWS_SECRET_KEY)," \
	hack/addons/thanos-object-storage.yaml

remove-thanos-obj-storage-yaml:
	rm hack/addons/thanos-object-storage.yaml

disable-obs:
	echo "WARNING: This will disable the observability addon for all managed clusters"
	${KUBECTL} delete -f hack/addons/multiclusterobservability_cr.yaml || true

enable-app-search-obs: enable-app enable-search disable-policy disable-cluster-proxy
enable-policy-search-obs: enable-policy enable-search disable-app disable-cluster-proxy
enable-policy-proxy-obs: enable-policy enable-cluster-proxy disable-app disable-search
enable-all: enable-obs-from-scratch enable-app enable-policy enable-search enable-cluster-proxy


# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

generate-cronjob:
	cd deploy && ./generate.sh $(MANAGED_CLUSTER_NAME) && ls output

create-cronjob:
	${KUBECTL} apply -k ./deploy/ 

delete-cronjob:
	${KUBECTL} delete -k ./deploy/ 

cronjob: generate-cronjob create-cronjob
clean-cronjob: generate-cronjob delete-cronjob

analysis:
	./deploy/analysis.sh $(MANAGED_CLUSTER_NAME)

build-images:
	docker build -t ${IMAGE_REGISTRY}/acm-workload:${IMAGE_TAG} -f Dockerfile .

push-images:
	docker push ${IMAGE_REGISTRY}/acm-workload:${IMAGE_TAG}

build-push-images: build-images push-images
