KAFKA_CLUSTER_NAMESPACE ?= kafka-cluster
CHAOS_SCHEDULE_INCLUDED_DAYS ?= Mon,Tue,Wed,Thu,Fri
CHAOS_SCHEDULE_INCLUDED_HOURS ?= 8-17
CHAOS_SCHEDULE_STATE ?= active
CHAOS_SCHEDULE_APP_LABEL ?= app.kubernetes.io/name=kafka
CHAOS_SCHEDULE_DEPLOYMENT_TYPE ?= statefulset
CHAOS_SCHEDULE_CLEANUP ?= retain
CHAOS_SCHEDULE_DURATION ?= 60
CHAOS_SCHEDULE_INTERVAL ?= 15m
CHAOS_SCHEDULE_FORCE ?= false

POD_DELETE_APP_LABEL ?= app.kubernetes.io/name=kafka
POD_DELETE_DEPLOYMENT_TYPE ?= statefulset
POD_DELETE_CLEANUP ?= retain
POD_DELETE_DURATION ?= 60
POD_DELETE_INTERVAL ?= 10
POD_DELETE_FORCE ?= false

.PHONY: create/operator/litmus
create/operator:
	@echo "create operator: litmus"
	@kubectl apply -f ./operator/litmus-operator-v1.8.2.yaml

.PHONY: create/chaosexperiments
create/chaosexperiments:
	@echo "create chaosexperiment resources"
	@kubectl apply -f ./chaosexperiments/chaosexperiments-generic.yaml
	@kubectl apply -f ./chaosexperiments/chaosexperiments-kafka.yaml

.PHONY: create/operator/chaosscheduler
create/operator/chaosscheduler: 
	@echo "create operator: litmus"
	@kubectl apply -f ./chaosscheduler/chaosscheduler-operator-v1.9.0.yaml

.PHONY: create/chaosschedule/pod-delete
create/chaosschedule/pod-delete: 
	@echo "create pod-delete chaosschedule"
	@cat ./chaosscheduler/chaosschedule-pod-delete.yaml | \
    sed -e 's|<chaos-schedule-interval>|$(CHAOS_SCHEDULE_INTERVAL)|g' | \
    sed -e 's|<chaos-schedule-included-days>|$(CHAOS_SCHEDULE_INCLUDED_DAYS)|g' | \
    sed -e 's|<chaos-schedule-included-hours>|$(CHAOS_SCHEDULE_INCLUDED_HOURS)|g' | \
    sed -e 's|<chaos-schedule-state>|$(CHAOS_SCHEDULE_STATE)|g' | \
    sed -e 's|<namespace>|$(KAFKA_CLUSTER_NAMESPACE)|g' | \
    sed -e 's|<pod-label>|$(CHAOS_SCHEDULE_APP_LABEL)|g' | \
    sed -e 's|<deployment-type>|$(CHAOS_SCHEDULE_DEPLOYMENT_TYPE)|g' | \
    sed -e 's|<cleanup>|$(CHAOS_SCHEDULE_CLEANUP)|g' | \
    sed -e 's|<chaos-duration>|$(CHAOS_SCHEDULE_DURATION)|g' | \
    sed -e 's|<chaos-interval>|$(CHAOS_SCHEDULE_INTERVAL)|g' | \
    sed -e 's|<force-delete>|$(CHAOS_SCHEDULE_FORCE)|g' | \
    cat | oc apply -f -

.PHONY: create/chaosengine/pod-delete
create/chaosengine/pod-delete: 
	@echo "create pod-delete chaosengine"
	@cat ./chaosengines/pod-delete/chaosengine.yaml | \
    sed -e 's|<namespace>|$(KAFKA_CLUSTER_NAMESPACE)|g' | \
    sed -e 's|<pod-label>|$(POD_DELETE_APP_LABEL)|g' | \
    sed -e 's|<deployment-type>|$(POD_DELETE_DEPLOYMENT_TYPE)|g' | \
    sed -e 's|<cleanup>|$(POD_DELETE_CLEANUP)|g' | \
    sed -e 's|<chaos-duration>|$(POD_DELETE_DURATION)|g' | \
    sed -e 's|<chaos-interval>|$(POD_DELETE_INTERVAL)|g' | \
    sed -e 's|<force-delete>|$(POD_DELETE_FORCE)|g' | \
    cat | oc apply -f -

all: create/operator create/chaosexperiments create/operator/chaosscheduler create/chaosengine/pod-delete
	@echo "Done deploying chaos experiments"
