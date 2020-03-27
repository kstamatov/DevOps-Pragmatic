#!/bin/bash

vars=($@)

env=${vars[0]}
label=${vars[1]}
name=${vars[2]}

if [[ $env == "dev" ]]    #in case of chartmuseum, chartmuseum/test-app
then helm upgrade --install test-app test-app/ --install --wait --set Deployment.Name=$env-$name,Deployment.label=$env-$label
elif [[ $env == "stage" ]]
then helm upgrade test-app test-app/ --install --wait --set Deployment.Name=$env-$name,Deployment.label=$env-$label
else echo "Invalid paramemters"
fi
