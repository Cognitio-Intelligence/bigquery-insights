from google.cloud import bigquery
from google.cloud.bigquery_datatransfer_v1 import DataTransferServiceClient
from google.cloud.bigquery_datatransfer_v1 import TransferConfig
from google.protobuf.timestamp_pb2 import Timestamp
from google.oauth2 import service_account
import yaml
import os
import datetime

def get_credentials(service_account_path):
    """Get credentials from service account JSON file."""
    try:
        credentials = service_account.Credentials.from_service_account_file(
            service_account_path,
            scopes=["https://www.googleapis.com/auth/cloud-platform"]
        )
        return credentials
    except Exception as e:
        print(f"Error loading service account credentials: {str(e)}")
        return None

def create_dataset(client, project_id, dataset_id, location):
    """Creates a dataset in the specified project."""
    dataset_ref = f"{project_id}.{dataset_id}"
    
    try:
        dataset = bigquery.Dataset(dataset_ref)
        dataset.location = location
        dataset.default_partition_expiration_ms = 60 * 24 * 60 * 60 * 1000  # 60 days
        client.create_dataset(dataset, exists_ok=True)
        print(f"Created dataset {dataset_ref}")
    except Exception as e:
        print(f"Error creating dataset {dataset_ref}: {str(e)}")

def create_scheduled_query(bq_client, transfer_client, project_id, query_file, schedule, dataset_id, location):
    """Creates or updates a scheduled query."""
    if not os.path.exists(query_file):
        print(f"Warning: Query file {query_file} does not exist. Skipping.")
        return
    
    try:
        # Read the query from file
        with open(query_file, 'r') as f:
            query = f.read()
        
        # Replace variables in the query
        query = query.replace("${PROJECT_ID}", project_id)
        query = query.replace("${DATASET_ID}", dataset_id)
        query = query.replace("${REGION}", location)
        
        # Get service account email from credentials
        service_account_email = bq_client._credentials.service_account_email
        
        # Create transfer configuration
        parent = f"projects/{project_id}/locations/{location}"
        display_name = f"Scheduled Query - {os.path.basename(query_file)}"
        
        transfer_config = TransferConfig(
            display_name=display_name,
            destination_dataset_id=dataset_id,
            data_source_id="scheduled_query",
            params={
                "query": query,
                "destination_table_name_template": os.path.splitext(os.path.basename(query_file))[0],
                "write_disposition": "WRITE_TRUNCATE"
            },
            schedule=schedule,
            data_refresh_window_days=1,  # Refresh data from the past day
        )
        
        # Check if config already exists
        existing_configs = transfer_client.list_transfer_configs(parent=parent)
        for config in existing_configs:
            if config.display_name == display_name:
                print(f"Updating existing scheduled query: {display_name}")
                # Update existing config
                update_mask = {"paths": ["params", "schedule"]}
                response = transfer_client.update_transfer_config(
                    transfer_config=config,
                    update_mask=update_mask
                )
                print(f"Updated scheduled query {query_file} with id: {response.name}")
                return
        
        # Create new config if it doesn't exist
        response = transfer_client.create_transfer_config(
            request={
                "parent": parent,
                "transfer_config": transfer_config,
                "service_account_name": service_account_email,
                "version_info": "1.0"
            }
        )
        
        print(f"Created new scheduled query {query_file} with id: {response.name}")
        
    except Exception as e:
        print(f"Error scheduling query {query_file}: {str(e)}")

def main():
    # Load service account credentials
    credentials = get_credentials("gpt_as_dataanalyst IAM Admin.json")
    if not credentials:
        return
    
    # Read configuration from YAML file
    with open('config.yaml', 'r') as f:
        config = yaml.safe_load(f)
    
    # Initialize clients with service account credentials
    bq_client = bigquery.Client(credentials=credentials, project=config['project_id'])
    transfer_client = DataTransferServiceClient(credentials=credentials)
    
    # Get configuration values
    project_id = config['project_id']
    dataset_id = config['dataset_id']
    location = config['LOCATION'].lower()
    
    # Create dataset with partition expiration
    create_dataset(bq_client, project_id, dataset_id, location)
    
    # Schedule queries from the scheduled_queries list
    for query_config in config['scheduled_queries']:
        create_scheduled_query(
            bq_client,
            transfer_client,
            project_id,
            f"sql/{query_config['query_file']}",
            query_config['schedule'],
            dataset_id,
            location
        )

if __name__ == "__main__":
    main() 