# Starting pipeline runs

There are three ways to trigger runs of the example pipelines:
- Using the Kubeflow Pipelines UI
- Using the KFP CLI tool
- Using the KFP SDK `kfp.Client()` API


## Running the pipelines using Kubeflow Pipelines UI

Use the procedure described in [Pipelines Quickstart](https://www.kubeflow.org/docs/pipelines/pipelines-quickstart/) to create experiments and submit pipeline runs.

The compiled training pipeline has been stored by Cloud Build in the following GCS location:

`gs://[_BUCKET_NAME][_PIPELINES_FOLDER]/[_TRAIN_PIPELINE].tar.gz`

The compiled batch predict pipeline is in

`gs://[_BUCKET_NAME][_PIPELINES_FOLDER]/[_PREDICT_PIPELINE].tar.gz`

In addition, both pipelines have been uploaded to your AI Platform Pipelines instance.

The sample training and testing datasets can be found in:

`gs://[_BUCKET_NAME][_SAMPLE_DATASET]`

The runtime parameters required by the pipelines are described in detail in [`/pipelines/README.md`](/pipelines/README.md)

Most of the parameters have reasonable default values that don't have to be modified during the intial runs.

## Running the pipelines using the KFP CLI tool

The [KFP CLI tool](https://www.kubeflow.org/docs/pipelines/sdk/sdk-overview/) enables you to use a subset of the Kubeflow Pipelines SDK directly from the command line. 

### Start a run of the *CLV Continuous Training* pipeline

Set the below environment variables to the values reflecting your environment. 

- `PROJECT_ID` - your GCP project ID
- `ENDPOINT` - set the `ENDPOINT` constant to the endpoint to your AI Platform Pipelines instance. Then endpoint to the AI Platform Pipelines instance can be found on the [AI Platform Pipelines](https://console.cloud.google.com/ai-platform/pipelines/clusters) page in the Google Cloud Console.
- `ARTIFACT_STORE` - the GCS bucket created during installation of AI Platform Pipelines. The bucket name starts with the `hostedkfp-default-` prefix.
- `REGION` - the compute region for AutoML Tables

```
export PROJECT_ID=[YOUR_PROJECT_ID
export ENDPOINT=[YOUR_AI_PLATFORM_PIPELINES_ENDPOINT]
export ARTIFACT_STORE_URI=[YOUR_ARTIFACT_STORE_URI]
export REGION=[YOUR_COMPUTE_REGION]
```

List the pipelines uploaded to your AI Platform Pipelines instance
```
kfp --endpoint $ENDPOINT pipeline list
```

Find the ID of the continuous training pipeline and update the value of PIPELINE_ID. During the build, the default name of the pipeline was set to `train_pipeline`.
```
PIPELINE_ID=[TRAINING_PIPELINE_ID]
```

Set the name of an experiment to use for the run, the run ID, and the pipeline's runtime parameters.
```
EXPERIMENT_NAME=CLV_Training
RUN_ID=Run_001

SOURCE_GCS_PATH=${ARTIFACT_STORE_URI}/dataset/transactions.csv
STAGING_GCS_PATH=${ARTIFACT_STORE_URI}/staging/features.csv
SOURCE_BQ_TABLE=""
BQ_DATASET_NAME=""
TRANSACTION_TABLE_NAME=transactions
FEATURES_TABLE_NAME=features
PREDICT_END=2011-12-12
THRESHOLD_DATE=2011-08-08
MAX_MONETARY=15000
```

Start the run
```
kfp --endpoint $ENDPOINT run submit \
-e $EXPERIMENT_NAME \
-r $RUN_ID \
-p $PIPELINE_ID \
project_id=$PROJECT_ID \
source_gcs_path=$SOURCE_GCS_PATH \
staging_gcs_path=$STAGING_GCS_PATH \
source_bq_table=$SOURCE_BQ_TABLE \
bq_dataset_name=$BQ_DATASET_NAME \
transactions_table_name=$TRANSACTION_TABLE_NAME \
features_table_name=$FEATURES_TABLE_NAME \
predict_end=$PREDICT_END \
threshold_date=$THRESHOLD_DATE \
max_monetary=$MAX_MONETARY 
```
 You can monitor the run using the KFP UI.

### Start a run of the *CLV Batch Predict* pipeline


Update the value of PIPELINE_ID. During the build, the default name of the pipeline was set to `predict_pipeline`.

```
PIPELINE_ID=[PREDICT_PIPELINE_ID]
```

Set the name of an experiment to use for the run, the run ID, and the pipeline's runtime parameters.
```
AML_MODEL_ID=[YOUR_MODEL_ID]

EXPERIMENT_NAME=CLV_Batch_Predict
RUN_ID=Run_001
DESTINATION_PREFIX=bq://${PROJECT_ID}
SOURCE_GCS_PATH=${ARTIFACT_STORE_URI}/dataset/test_transactions.csv
STAGING_GCS_PATH=${ARTIFACT_STORE_URI}/staging/features.csv
SOURCE_BQ_TABLE=""
BQ_DATASET_NAME=""
PREDICT_END=2011-12-09
THRESHOLD_DATE=2011-12-08
MAX_MONETARY=15000
```

Start the run
```
kfp --endpoint $ENDPOINT run submit \
-e $EXPERIMENT_NAME \
-r $RUN_ID \
-p $PIPELINE_ID \
project_id=$PROJECT_ID \
source_gcs_path=$SOURCE_GCS_PATH \
staging_gcs_path=$STAGING_GCS_PATH \
source_bq_table=$SOURCE_BQ_TABLE \
bq_dataset_name=$BQ_DATASET_NAME \
predict_end=$PREDICT_END \
threshold_date=$THRESHOLD_DATE \
max_monetary=$MAX_MONETARY \
aml_model_id=$AML_MODEL_ID \
destination_prefix=$DESTINATION_PREFIX
```

### Running the pipelines using KFP SDK

You can also use the `kfp.Client()` API from the [KFP SDK](https://www.kubeflow.org/docs/pipelines/sdk/sdk-overview/) to upload pipelines to a KFP environment, create experiments, and start runs.





