# kafka-monitoring-stuff

## Installation

The `install` folder contains resource files and a Makefile to provision a strimzi operator, kafka cluster and our monitoring stack on an openshift cluster.

### Prerequisites

- [strimz-kafka-operator repo](https://github.com/strimzi/strimzi-kafka-operator)
- [grafana-operator repo](https://github.com/integr8ly/grafana-operator)
- oc and kubectl binaries
- running openshift 4 cluster and kubeadmin credentials

### Installation via Makefile

Makefile assumes you have the following local env vars set:
- STRIMZI_OPERATOR_REPO: path-to-local-strimzi-kafka-operator-repo
- GRAFANA_OPERATOR_REPO: path-to-local-grafana-operator-repo

If you do not have these env vars set/ wish to use other local repos you will need to pass the appropriate values into the make command, ie

```
make install/operator STRIMZI_OPERATOR_REPO=<PATH-TO-LOCAL-REPO>  
make install/grafana GRAFANA_OPERATOR_REPO=<PATH-TO-LOCAL-REPO>
```

Available `make` targets:

```sh
# remove cluster resources added with this tooling
make install/clean 

# deploy strimzi operator to cluster
make install/operator 

# create kafka cluster
make install/cluster 

# deploy and update resources for monitoring
make install/monitoring 

# install grafana instance for monitoring
make install/grafana
```


### Manual installation

If a manual installation is preferred follow the manual steps in `install/installation-guide.md`.