# BigQuery Dataset Setup Automation

This tool automates the creation of BigQuery datasets and scheduling of queries based on a YAML configuration file.

## Prerequisites

1. Google Cloud SDK installed and configured
2. Python 3.7+
3. Required permissions:
   - BigQuery Admin (`roles/bigquery.admin`)
   - BigQuery Data Transfer Service Admin (`roles/bigquerydatatransfer.admin`)
   - Cloud Resource Manager Viewer (`roles/resourcemanager.projectViewer`)

## Authentication Setup

1. **Grant required permissions**:
   ```bash
   # Replace [USER_EMAIL] with your email
   gcloud projects add-iam-policy-binding [PROJECT_ID] \
       --member="user:[USER_EMAIL]" \
       --role="roles/bigquery.admin"

   gcloud projects add-iam-policy-binding [PROJECT_ID] \
       --member="user:[USER_EMAIL]" \
       --role="roles/bigquerydatatransfer.admin"

   gcloud projects add-iam-policy-binding [PROJECT_ID] \
       --member="user:[USER_EMAIL]" \
       --role="roles/resourcemanager.projectViewer"
   ```

2. **Authenticate with gcloud**:
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

3. **Enable required APIs**:
   ```bash
   gcloud services enable bigquerydatatransfer.googleapis.com
   gcloud services enable cloudresourcemanager.googleapis.com
   ```

2. **Run the script**:
   - The script will provide a URL for authentication
   - Open the URL in your browser
   - Authorize the application
   - Copy the authorization code
   - Paste it when prompted

## Setup

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Configure your datasets:
   - Edit the `config.yaml` file
   - Add your dataset configurations
   - Schedule formats should be in the format "every X hours/minutes/days"

3. Run the setup script:
   ```bash
   python setup_datasets.py
   ```

## Configuration Format (config.yaml)

| Column | Description | Example |
|--------|-------------|---------|
| project_id | GCP Project ID | my-project-123 |
| dataset_id | BigQuery Dataset Name | bigquery_usage |
| location | Dataset Location | US or EU |
| project_number | GCP Project Number | 507816165461 |
| daily_usage_schedule | Schedule for daily usage query | every 24 hours |
| tb_billed_schedule | Schedule for TB billed query | every 1 hour |
| slot_usage_schedule | Schedule for slot usage query | every 24 hours |
| alert_schedule | Schedule for alerts | every 15 minutes |
| most_used_schedule | Schedule for most used tables | every 24 hours |
| errors_schedule | Schedule for error tracking | every 24 hours |

## Troubleshooting

1. Authentication Errors:
   - Ensure you've completed the authentication setup
   - Check that your service account has the required permissions
   - Verify the service account JSON file is accessible

2. Scheduling Errors:
   - Verify the schedule format is correct
   - Check that the SQL files exist in the sql/ directory
   - Ensure the service account has permission to create transfer configs

## Support

For issues and questions, please create an issue in the repository.

## Spreadsheet Columns

- project_id: GCP project ID
- dataset_id: Name for the BigQuery dataset
- location: Dataset location (e.g., US, EU)
4. Set up the AppScript project:
   - Create a new Google Apps Script project
   - Copy the contents of `appscript/Code.gs` and `appscript/appsscript.json` into your project
   - Update the `spreadsheetId`, `teamsWebhookUrl`, and `slackWebhookUrl` in `Code.gs`
   - Run the `createTrigger` function to set up the hourly alert check
5. Import the dashboard template into Data Studio (now Looker Studio):
   - Create a new Data Studio report
   - Use the `dashboard_template.json` as a reference to set up your visualizations
   - Connect your BigQuery data sources

## Components

- Scheduled Queries: Automated data processing in BigQuery
- AppScript Alerts: Sends notifications to Teams and Slack based on performance thresholds
- Dashboard Template: Visualizes insights from processed data in Looker Studio

## Customization

- Modify the SQL queries in the `sql/` directory to fit your data structure and requirements
- Adjust the alert conditions in the `sendAlerts` function in `appscript/Code.gs`
- Customize the dashboard components in `dashboard/dashboard_template.json` to match your reporting needs

## Maintenance

Regularly check the BigQuery scheduled queries and AppScript logs to ensure everything is running smoothly. Update the queries and alert thresholds as your business needs evolve.