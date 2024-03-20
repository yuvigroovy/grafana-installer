#! /usr/bin/bash

# --- output schema ---
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
NC='\033[0m' 

# --- create namespace ---
echo -e "${BLUE}enter namespace for grafana:${NC} \033[0K\r"
read namespace
echo

echo -ne "[INFO]  -  createing namespace  -  ${YELLOW}IN-PROGRESS${NC} \033[0K\r"
oc new-project $namespace &> /dev/null
sleep 0.5
echo -ne "[INFO]  -  createing namespace  -  ${GREEN}DONE${NC} \033[0K\r"
echo    

# --- deploy operator ---
echo -ne "[INFO]  -  deploying grafana operator  -  ${YELLOW}IN-PROGRESS${NC} \033[0K\r"
oc create -f ./grafana-operator.yaml -n $namespace &> /dev/null
oc -n $namespace rollout status \deployment grafana-operator-controller-manager &> /dev/null
sleep 0.5
echo -ne "[INFO]  -  deploying grafana operator  -  ${GREEN}DONE${NC} \033[0K\r"
echo    


# --- deploy grafana instance ---
echo -ne "[INFO]  -  deploying grafana instance  -  ${YELLOW}IN-PROGRESS${NC} \033[0K\r"
helm repo add mobb https://rh-mobb.github.io/helm-charts/ &> /dev/null
helm upgrade --install -n grafana-operator \grafana mobb/grafana-cr &> /dev/null
sleep 0.5
echo -ne "[INFO]  -  deploying grafana instance  -  ${GREEN}DONE${NC} \033[0K\r"
echo    

# --- set role to grafana ---
oc adm policy add-cluster-role-to-user \cluster-monitoring-view -z grafana-serviceaccount -n $namespace &> /dev/null
BEARER_TOKEN=$(oc create token grafana-serviceaccount &> /dev/null) &> /dev/null


# --- create datasource ---
echo
echo -e "${BLUE}enter thanos host:${NC} \033[0K\r"
read thanos_host
echo

echo -ne "[INFO]  -  createing data source  -  ${YELLOW}IN-PROGRESS${NC} \033[0K\r"
oc apply -f ./grafana-datasource.yaml -n $namespace &> /dev/null
sleep 0.5
echo -ne "[INFO]  -  createing data source  -  ${GREEN}DONE${NC} \033[0K\r"
echo    

# --- create dashbord ---
echo -ne "[INFO]  -  createing dashboard  -  ${YELLOW}IN-PROGRESS${NC} \033[0K\r"
oc apply -f ./grafana-dashbord.yaml -n $namespace &> /dev/null
sleep 0.5
echo -ne "[INFO]  -  createing dashboard  -  ${GREEN}DONE${NC} \033[0K\r"
echo    

# --- get route ---
echo 
echo -ne "[INFO]  -  ${YELLOW}ROUTE${NC}  -  "${BLUE} $(oc get route grafana-route -n $namespace 2> /dev/null) ${NC}
echo

echo

echo "*****************"
echo -e "*${GREEN} --- DONE --- ${NC}* \033[0K\r"
echo "*****************"

