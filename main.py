from google.cloud import bigquery
from google.cloud.exceptions import NotFound

client = bigquery.Client()

# TODO(developer): Set dataset_id to the ID of the dataset to determine existence.
# dataset_id = "your-project.your_dataset"

try:
    client.get_dataset(dataset_id)  # Make an API request.
    print("Dataset {} already exists".format("${PROJECT_ID}.${DATASET_ID}"))
except NotFound:
    print("Dataset {} is not found".format("${PROJECT_ID}.${DATASET_ID}"))