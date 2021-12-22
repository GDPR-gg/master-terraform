# Frequent Asked Questions

## Where to browse the dataset tables?

The datasets are hosted in a separate project from the team projects, as a
result, by default they don't show up on the BigQuery console. Please follow the
instructions below to display the datasets on the left panel so you can browse.

*   Go to the [BigQuery console](https://bigquery.cloud.google.com/welcome).

*   If you are logged in to your team account, you should see your project name
    in the sidebar.

*   Click the caret to the right of the project name

![Caret](tutorials/images/caret.png)

*   Hover over "Switch to project", scroll down to the bottom and click "Display
    project"

![Switch project](tutorials/images/switch_project.png)

![Display project](tutorials/images/display_project.png)

*   Input `bigquery-public-data` as the project name and click "OK"

![Add project](tutorials/images/add_project.png)

*   Now you should be able to browse the tables on the left panel

![Browse datasets](tutorials/images/datasets.png)

## What are the RStudio login credentials?

These credientials should have been provided to you by the organizer of the
datathon.

## What is the link to colab service?

http://colab.research.google.com

During the datathon, please make sure to use the following link which is the
latest version:
http://colab.research.google.com/github/GoogleCloudPlatform/healthcare/blob/master/datathon/cms_medicare/tutorials/bigquery_tutorial.ipynb

## Why does my BigQuery query fail?

*   First, check whether you have "Use legacy SQL" unchecked, detailed
    instructions:
    https://github.com/GoogleCloudPlatform/healthcare/blob/master/datathon/cms_medicare/tutorials/bigquery_ui.md#sql-dialect

*   Second, make sure the query validator is green before running the query

![Query validator](tutorials/images/query_validator.png)

If the query still doesn't work, ask for help.
