#!/bin/bash

# we will move any code provided by s2i to here
LOCAL_SOURCE_DIR=${HOME}/source

# Resulting WAR files will be deployed to /opt/eap/standalone/deployments
DEPLOY_DIR=$JBOSS_HOME/standalone/deployments

CONFIG_FILE=${JBOSS_HOME}/standalone/configuration/standalone-openshift.xml

function find_env() {
  var=${!1}
  echo "${var:-$2}"
}

function configure_translators() {
  if [ $# == 1 ] && [ -f "$1" ]; then
    source $1
  fi

  teiid_translators=

  if [ -n "$TRANSLATORS" ]; then
    for t_prefix in $(echo $TRANSLATORS | sed "s/,/ /g"); do
      t_name=$(find_env ${t_prefix}_NAME)
      if [ -z "$t_name" ]; then
        echo "Warning - ${t_prefix}_NAME  is missing from translator configuration. Translator will not be configured"
        continue
      fi

      t_module=$(find_env ${t_prefix}_MODULE)
      if [ -z "$t_module" ]; then
        echo "Warning - ${t_prefix}_MODULE  is missing from translator configuration. Translator will not be configured"
        continue
      fi

      teiid_translators="$teiid_translators <translator name=\"${t_name}\" module=\"${t_module}\"/>"
    done
  fi
 
  sed -i "s|<!-- ##TEIID_TRANSLATORS## -->|${teiid_translators}|" "${CONFIG_FILE}"
}
