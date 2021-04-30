.PHONY: create/namespace
create/namespace:
	@echo "create namespace: $(OBSERVATORIUM_MONITORING)"
	@sed 's/<namespace>/$(OBSERVATORIUM_MONITORING)/g' ./namespace.yaml | cat | oc apply -f -

.PHONY: create/prometheus
create/prometheus:
	@echo "installing prometheus: $(OBSERVATORIUM_MONITORING_PROMETHEUS)"
	@cat ./operator-group.yaml | sed -e 's/<namespace>/$(OBSERVATORIUM_MONITORING)/g' | \
		sed -e 's/<name>/$(OBSERVATORIUM_MONITORING)/g' | \
		cat | oc apply -f -
	@cat ./prometheus.yaml | sed -e 's/<namespace>/$(OBSERVATORIUM_MONITORING)/g' | \
		sed -e 's/<name>/$(OBSERVATORIUM_MONITORING_PROMETHEUS)/g' | \
		sed -e 's/<namespace>/$(OBSERVATORIUM_MONITORING)/g' | \
		sed -e 's/<cluster__id>/$(CLUSTER_ID)/g' | \
		cat | oc apply -f -
	@echo "Waiting for the prometheus operator to be ready"
	@for i in {1..12}; do oc -n $(OBSERVATORIUM_MONITORING) get pod -l k8s-app=prometheus-operator -o name | grep "pod/prometheus-operator" && break || sleep 5; done	
	@echo "creating prometheusrules"
	@sed 's/<namespace>/$(OBSERVATORIUM_MONITORING)/g' ./prometheus-rules/prometheus-rules.yaml | cat | oc apply -f -	


.PHONY: create/grafana
create/grafana:
	@echo "create grafana: $(OBSERVATORIUM_MONITORING_GRAFANA)"
	@cat ./grafana-sub.yaml | sed -e 's/<namespace>/$(OBSERVATORIUM_MONITORING)/g' | \
		sed -e 's/<name>/$(OBSERVATORIUM_MONITORING_GRAFANA)/g' | \
		cat | oc apply -f -	
	@ echo "Waiting for Grafana CRD to be created"
	@ for i in {1..12}; do oc get crd grafanas.integreatly.org && break || sleep 5; done
	@cat ./grafana.yaml | sed -e 's/<namespace>/$(OBSERVATORIUM_MONITORING)/g' | \
		sed -e 's/<name>/$(OBSERVATORIUM_MONITORING_GRAFANA)/g' | \
		sed -e 's/<prom_url>/$(PROM_URL)/g' | \
		cat | oc apply -f -	
	@echo "creating kafka cluster dashboards"
	@cat ./dashboards/test_dash.yaml | sed -e 's/<namespace>/$(OBSERVATORIUM_MONITORING)/g' | cat | oc apply -f -

all: create/namespace create/prometheus create/grafana 

clean:
	@oc delete namespace $(OBSERVATORIUM_MONITORING)
	@echo "Done uninstalling observatorium-monitoring"
