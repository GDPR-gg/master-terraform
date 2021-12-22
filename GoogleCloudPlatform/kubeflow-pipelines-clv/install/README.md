# Configuring AI Platform Pipelines

1. Select or create a [Google Cloud project](https://cloud.google.com/resource-manager/docs/creating-managing-projects). You must be the [Project Owner](https://cloud.google.com/iam/docs/understanding-roles) to complete the configuration.
2. Launch [Cloud Shell](https://cloud.google.com/shell/docs/launching-cloud-shell)
3. Enable Cloud Services utilized by the pipelines. In addition to the services [enabled by default](https://cloud.google.com/service-usage/docs/enabled-service) you need to enable the following additional services:
   - Compute Engine
   - Container Registry
   - Kubernetes Engine
   - AutoML 
   - Cloud Build
   - Cloud Resource Manager
```
PROJECT_ID=[YOUR PROJECT ID]

gcloud config set project $PROJECT_ID

gcloud services enable \
cloudbuild.googleapis.com \
container.googleapis.com \
cloudresourcemanager.googleapis.com \
iam.googleapis.com \
containerregistry.googleapis.com \
containeranalysis.googleapis.com \
automl.googleapis.com
```
4. Add the **Cloud Build** service account to the **Project Editor** role. 
```
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
CLOUD_BUILD_SERVICE_ACCOUNT="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$CLOUD_BUILD_SERVICE_ACCOUNT \
  --role roles/editor
```
5. Create an instance of **AI Platform Pipelines**. Follow the [Setting up AI Platform Pipelines](https://cloud.google.com/ai-platform/pipelines/docs/setting-up) how-to guide. Make sure to enable the access to `https://www.googleapis.com/auth/cloud-platform` when creating a GKE cluster.

