STRIMZI_OPERATOR_REPO ?= ${STRIMZI_OPERATOR_REPO}
STRIMZI_OPERATOR_TAG ?= 0.19.0
STRIMZI_OPERATOR_NAMESPACE ?= openshift-kafka-operator
KAFKA_CLUSTER_NAMESPACE ?= openshift-kafka-cluster
GRAFANA_OPERATOR_REPO ?= ${GRAFANA_OPERATOR_REPO}
GRAFANA_NAMESPACE ?= kafka-grafana
BUILD_FILES_DIRNAME := deploy_$(shell date +%y%m%d_%H%M%S)
RESOURCE_FILES_DIR ?= ./resources

.PHONY: install/operator
install/operator:
	# fetch files
	@ mkdir $(BUILD_FILES_DIRNAME)
	@ cp -r $(STRIMZI_OPERATOR_REPO)/install/cluster-operator/ ./$(BUILD_FILES_DIRNAME)

	# create namespaces
	@ kubectl create ns $(STRIMZI_OPERATOR_NAMESPACE)
	@ kubectl create ns $(KAFKA_CLUSTER_NAMESPACE)

	# update rolebindings
	@ sed -i 's/namespace: .*/namespace: $(STRIMZI_OPERATOR_NAMESPACE)/' ./$(BUILD_FILES_DIRNAME)/cluster-operator/*RoleBinding*.yaml

	# Update cluster ns operator will watch
	@ sed -i 's/valueFrom:/value: $(KAFKA_CLUSTER_NAMESPACE)/' ./$(BUILD_FILES_DIRNAME)/cluster-operator/050-Deployment-strimzi-cluster-operator.yaml
	@ sed -i '/fieldRef/d' ./$(BUILD_FILES_DIRNAME)/cluster-operator/050-Deployment-strimzi-cluster-operator.yaml
	@ sed -i '/fieldPath/d' ./$(BUILD_FILES_DIRNAME)/cluster-operator/050-Deployment-strimzi-cluster-operator.yaml

	# Deploy operator
	@ oc apply -f ./$(BUILD_FILES_DIRNAME)/cluster-operator -n $(STRIMZI_OPERATOR_NAMESPACE)

	# remove deployment files
	@ rm -rf ./$(BUILD_FILES_DIRNAME)

.PHONY: install/cluster
install/cluster:
	# fetch files
	@ mkdir $(BUILD_FILES_DIRNAME)
	@ cp -r $(STRIMZI_OPERATOR_REPO)/install/cluster-operator/ ./$(BUILD_FILES_DIRNAME)

	# create rolebindings to allow operator to watch kafka cluster ns
	@ oc apply -f ./$(BUILD_FILES_DIRNAME)/cluster-operator/020-RoleBinding-strimzi-cluster-operator.yaml -n $(KAFKA_CLUSTER_NAMESPACE)
	@ oc apply -f ./$(BUILD_FILES_DIRNAME)/cluster-operator/032-RoleBinding-strimzi-cluster-operator-topic-operator-delegation.yaml -n $(KAFKA_CLUSTER_NAMESPACE)
	@ oc apply -f ./$(BUILD_FILES_DIRNAME)/cluster-operator/031-RoleBinding-strimzi-cluster-operator-entity-operator-delegation.yaml -n $(KAFKA_CLUSTER_NAMESPACE)
	
	# create kafka cluster
	@ oc apply -f ./$(RESOURCE_FILES_DIR)/cluster/kafka.yaml -n $(KAFKA_CLUSTER_NAMESPACE)

	# create sample kafka topic
	@ oc apply -f ./$(RESOURCE_FILES_DIR)/cluster/kafka-topic.yaml -n $(KAFKA_CLUSTER_NAMESPACE)

	# remove deployment files
	@ rm -rf ./$(BUILD_FILES_DIRNAME)

.PHONY: install/monitoring
install/monitoring:
	# fetch files
	@ mkdir $(BUILD_FILES_DIRNAME)
	@ cp -r ./$(RESOURCE_FILES_DIR)/operator ./$(BUILD_FILES_DIRNAME)

	# label namespaces for cluster monitoring
	@ oc label namespace $(STRIMZI_OPERATOR_NAMESPACE) openshift.io/cluster-monitoring=true --overwrite
	@ oc label namespace $(KAFKA_CLUSTER_NAMESPACE) openshift.io/cluster-monitoring=true --overwrite

	# deploy pod monitors
	@ sed -i 's/<OPERATOR_NAMESPACE>/$(STRIMZI_OPERATOR_NAMESPACE)/' ./$(BUILD_FILES_DIRNAME)/operator/strimzi-pod-monitor.yaml
	@ sed -i 's/<CLUSTER_NAMESPACE>/$(KAFKA_CLUSTER_NAMESPACE)/' ./$(BUILD_FILES_DIRNAME)/operator/strimzi-pod-monitor.yaml
	@ oc apply -f ./$(BUILD_FILES_DIRNAME)/operator/strimzi-pod-monitor.yaml -n $(STRIMZI_OPERATOR_NAMESPACE)
	@ oc apply -f ./$(BUILD_FILES_DIRNAME)/operator/strimzi-pod-monitor.yaml -n $(KAFKA_CLUSTER_NAMESPACE)

	# create role and rolebinding for operator
	@ sed -i 's/namespace: .*/namespace: $(STRIMZI_OPERATOR_NAMESPACE)/' ./$(BUILD_FILES_DIRNAME)/operator/*kafka-operator-role*.yaml
	@ oc apply -f ./$(BUILD_FILES_DIRNAME)/operator/kafka-operator-role.yaml -n $(STRIMZI_OPERATOR_NAMESPACE)
	@ oc apply -f ./$(BUILD_FILES_DIRNAME)/operator/kafka-operator-rolebinding.yaml -n $(STRIMZI_OPERATOR_NAMESPACE)

	# create role and rolebinding for cluster
	@ cp -r ./$(RESOURCE_FILES_DIR)/cluster ./$(BUILD_FILES_DIRNAME)
	@ sed -i 's/namespace: .*/namespace: $(KAFKA_CLUSTER_NAMESPACE)/' ./$(BUILD_FILES_DIRNAME)/cluster/*kafka-project-role*.yaml
	@ oc apply -f ./$(BUILD_FILES_DIRNAME)/cluster/kafka-project-role.yaml -n $(KAFKA_CLUSTER_NAMESPACE)
	@ oc apply -f ./$(BUILD_FILES_DIRNAME)/cluster/kafka-project-rolebinding.yaml -n $(KAFKA_CLUSTER_NAMESPACE)

	# remove deployment files
	@ rm -rf ./$(BUILD_FILES_DIRNAME)

.PHONY: install/grafana
install/grafana:
	# fetch files
	@ mkdir $(BUILD_FILES_DIRNAME)
	@ cp -r $(GRAFANA_OPERATOR_REPO)/deploy/ ./$(BUILD_FILES_DIRNAME)

	# create namespace
	@ kubectl create namespace $(GRAFANA_NAMESPACE)

	# deploy resources
	@ kubectl create -f ./$(BUILD_FILES_DIRNAME)/deploy/crds -n $(GRAFANA_NAMESPACE)
	@ kubectl create -f ./$(BUILD_FILES_DIRNAME)/deploy/roles -n $(GRAFANA_NAMESPACE)
	@ kubectl create -f ./$(BUILD_FILES_DIRNAME)/deploy/cluster_roles -n $(GRAFANA_NAMESPACE)

	# deploy operator
	@ kubectl create -f ./$(BUILD_FILES_DIRNAME)/deploy/operator.yaml -n $(GRAFANA_NAMESPACE)
	
	# create grafana instance
	@ oc apply -f ./$(RESOURCE_FILES_DIR)/grafana/grafana.yaml -n $(GRAFANA_NAMESPACE)

	# remove deployment files
	@ rm -rf ./$(BUILD_FILES_DIRNAME)

.PHONY: install/clean
install/all:
	# remove namespaces and grafana crds
	@ kubectl delete ns $(STRIMZI_OPERATOR_NAMESPACE)
	@ kubectl delete ns $(KAFKA_CLUSTER_NAMESPACE)
	@ oc delete crds grafanadashboards.integreatly.org grafanadatasources.integreatly.org grafanas.integreatly.org

.PHONY: install/all
install/all: install/clean install/operator install/cluster install/monitoring install/grafana