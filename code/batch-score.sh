## IMPORTANT: this file and accompanying assets are the source for snippets in https://docs.microsoft.com/azure/machine-learning! 
## Please reach out to the Azure ML docs & samples team before before editing for the first time.

set -e

# <set_variables>
export ENDPOINT_NAME="demoedp"
export MODEL_NAME="mlflow-model"
# </set_variables>

# <set_deployment_name>
export NEW_DEPLOYMENT_NAME=deploy-`echo $RANDOM`
# </set_deployment_name>

# <create_compute>
az ml compute create -n batch-cluster --type amlcompute --min-instances 0 --max-instances 5
# </create_compute>

# <create_batch_endpoint>
az ml batch-endpoint create --name $ENDPOINT_NAME
# </create_batch_endpoint>

# <create_batch_deployment_latest_model>
LATEST_MODEL_VERSION=$(az ml model show -n $MODEL_NAME --query version -o tsv )
echo $LATEST_MODEL_VERSION
az ml batch-deployment create --name $NEW_DEPLOYMENT_NAME --endpoint-name $ENDPOINT_NAME --file batch-endpoint/mlflow-deployment.yml --set model=azureml:$MODEL_NAME:$LATEST_MODEL_VERSION
# </create_batch_deployment_latest_model>

# <verify_deployment>
# <start_batch_scoring_job>
JOB_NAME=$(az ml batch-endpoint invoke --name $ENDPOINT_NAME --deployment-name $NEW_DEPLOYMENT_NAME --input-local-path batch-endpoint/data/test_data.csv --query name -o tsv)
# </start_batch_scoring_job>

# <show_job_in_studio>
az ml job show -n $JOB_NAME --web
# </show_job_in_studio>

# <stream_job_logs_to_console>
az ml job stream -n $JOB_NAME
# </stream_job_logs_to_console>

# <check_job_status>
STATUS=$(az ml job show -n $JOB_NAME --query status -o tsv)
echo $STATUS
if [[ $STATUS == "Completed" ]]
then
  echo "Job completed"
elif [[ $STATUS ==  "Failed" ]]
then
  echo "Job failed"
  exit 1
else 
  echo "Job status not failed or completed"
  exit 2
fi
# </check_job_status>
# </verify_deployment>

# <mark_prod_deployment_if_not_exist>
PROD_DEPLOYMENT=$(az ml batch-endpoint show -n $ENDPOINT_NAME --query defaults.deployment_name -o tsv)
if [[ -z "$PROD_DEPLOYMENT" ]]; then
    # set the current deployment as prod/default
    az ml batch-endpoint update --name $ENDPOINT_NAME --defaults deployment_name=$NEW_DEPLOYMENT_NAME
    # exit. If the script is run again it will now create new deployment
    echo "Initial PROD deployment created. Rerun script to create a new deployment. Exiting."
    exit 0
fi
# </mark_prod_deployment_if_not_exist>

# <set_new_prod_deployment>
az ml batch-endpoint update --name $ENDPOINT_NAME --defaults deployment_name=$NEW_DEPLOYMENT_NAME
OLD_PROD_DEPLOYMENT=$PROD_DEPLOYMENT
PROD_DEPLOYMENT=$NEW_DEPLOYMENT_NAME
# </set_new_prod_deployment>

# <delete_old_prod_deployment>
az ml batch-deployment delete --name $OLD_PROD_DEPLOYMENT --yes
# </delete_old_prod_deployment>