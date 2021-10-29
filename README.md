# Auto deploy model using Azure ML Batch Endpoints

This repo shows the more extensive capabilities of using [GitHub Actions](https://github.com/features/actions) with [Azure Machine Learning](https://docs.microsoft.com/en-us/azure/machine-learning/) to automaticaly deploy model for batch scoring using [Batch Endpoints](https://docs.microsoft.com/en-us/azure/machine-learning/concept-endpoints#what-are-batch-endpoints-preview).

Learn more about [Use batch endpoints for batch scoring](https://docs.microsoft.com/en-us/azure/machine-learning/how-to-use-batch-endpoint).

# Getting started

### 1. Prerequisites

The following prerequisites are required to make this repository work:
- Azure subscription
- Owner of the Azure subscription
- Access to [GitHub Actions](https://github.com/features/actions)

If you don’t have an Azure subscription, create a free account before you begin. Try the [free or paid version of Azure Machine Learning](https://aka.ms/AMLFree) today.

### 2. Create repository

Fork this repo.

### 3. Setting up the required secrets

A service principal needs to be generated for authentication and getting access to your Azure subscription. We suggest adding a service principal with contributor rights to a new resource group or to the one where you have deployed your existing Azure Machine Learning workspace. Just go to the Azure Portal to find the details of your resource group or workspace. Then start the Cloud CLI or install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) on your computer and execute the following command to generate the required credentials:

```sh
# Replace {service-principal-name}, {subscription-id} and {resource-group} with your 
# Azure subscription id and resource group name and any name for your service principle
az ad sp create-for-rbac --name {service-principal-name} \
                         --role contributor \
                         --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group}
```

This will generate the following JSON output:

```sh
{
  "clientId": "<GUID>",
  "clientSecret": "<GUID>",
  "subscriptionId": "<GUID>",
  "tenantId": "<GUID>",
  (...)
}
```

Add this JSON output as [a secret](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets#creating-encrypted-secrets) with the name `AZURE_CREDENTIALS` in your GitHub repository:

<p align="center">
  <img src="docs/images/secrets.png" alt="GitHub Template repository" width="700"/>
</p>

To do so, click on the Settings tab in your repository, then click on Secrets and finally add the new secret with the name `AZURE_CREDENTIALS` to your repository.

Please follow [this link](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets#creating-encrypted-secrets) for more details. 

### 4. Define your workspace parameters

This example uses secrets to store your workspace parameters, please add `SUBSCRIPTION_ID`, `AML_WORKSPACE` and `RESOURCE_GROUP` as secrets in your GitHub repository.

### 5. Modify the code

Now you can start modifying the code in the <a href="/code">`code` folder</a>, so that your model and not the provided sample model gets trained on Azure. Where required, modify the job yaml so that the training environment will have the correct packages installed in the conda environment for your training.

The sample training code tracks the training job using MLflow, which will produce the model in MLflow format. And no-cod-deployment is supported for MLflow model when you create a batch endpoint. That is, there's no need to provide environment and scoring script, as both can be auto generated.

### 6. Kickoff auto deploy

Run the `train` GitHub action. It will kick off the train job and build the model. After it's completed, `auto-deploy-batch` action will automatically started.

If it's the first time run `auto-deploy-batch`, a batch endpoint will be created with a prod deployment host the trained model. Run the `train` action again will build a new versioned model and auto deploy the new versioned model under the same batch endpoint, and serves as the default batch deployment.

# Documentation

## Code structure

| File/folder                   | Description                                |
| ----------------------------- | ------------------------------------------ |
| `code`                        | Sample data science source code that will be submitted to Azure Machine Learning to train and deploy machine learning models. |
| `code/batch-endpoint/data/test_data.csv` | Sample input data to test the batch endpoint. |
| `code/batch-endpoint/mlflow-deployment.yml` | Batch deployment YML file to deploy the trained MLflow model. |
| `code/train/data/transformed_data.csv`  | Sample data to train the model. |
| `code/train/src/train.py`         | Training script that gets executed on a cluster on Azure Machine Learning. |
| `code/train/job.yml`  | Job YML file to define a training job. |
| `.github/workflows`           | Folder for GitHub workflows. The `auto_deploy.yml` sample workflow shows you how to use the Azure Machine Learning GitHub Actions to automate batch deployment with a new model. |
| `docs`                        | Resources for this README.                 |
| `CODE_OF_CONDUCT.md`          | Microsoft Open Source Code of Conduct.     |
| `LICENSE`                     | The license for the sample.                |
| `README.md`                   | This README file.                          |
| `SECURITY.md`                 | Microsoft Security README.                 |

# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
