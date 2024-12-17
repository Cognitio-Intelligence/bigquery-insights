# BigQuery Usage Monitoring & Alerting System

A comprehensive solution for monitoring BigQuery usage, costs, and performance metrics with automated alerting capabilities.

## Features

- Real-time usage monitoring
- Cost tracking and alerting
- Performance metrics visualization
- Automated alerts via Email, Teams, and Slack
- Custom dashboard in Looker Studio
- Scheduled data collection and processing

## Dashboard Overview

This monitoring solution is based on the [BigQuery System Tables Reports](https://github.com/GoogleCloudPlatform/bigquery-utils/tree/master/dashboards/system_tables) and includes the following reports:

1. Daily Utilization Report
2. Hourly Utilization Report
3. Reservation Utilization Report
4. Job Execution Report
5. Job Error Report
6. Job Comparison Report

## Prerequisites

- Google Cloud Platform account with BigQuery access
- Google Apps Script enabled
- Required GCP permissions:
  - BigQuery Admin (`roles/bigquery.admin`)
  - BigQuery Data Transfer Service Admin (`roles/bigquerydatatransfer.admin`)
  - Cloud Resource Manager Viewer (`roles/resourcemanager.projectViewer`)

## Setup Instructions

### 1. Configuration Spreadsheet Setup

1. Create a new Google Sheet
2. Set up a "Config" sheet with the following structure:

| Cell | Content Description |
|------|-------------------|
| B1   | GCP Project ID    |
| B2   | Dataset ID        |
| B3   | Location (US/EU)  |
| B4   | Alert Email       |
| B5   | Teams Webhook URL |
| B6   | Slack Webhook URL |

### 2. BigQuery Configuration

1. Create a new BigQuery dataset to store materialized views
2. Configure the dataset location (US or EU)
3. Note: The SQL files in the `sql/` directory will be executed via Apps Script triggers, not BigQuery scheduled queries

### 3. Apps Script Setup

1. Create a new Google Apps Script project
2. Copy the contents of `sheets_appscript.js` into your project
3. Set up the custom menu and triggers:
   - "Run BigQuery Daily Usage Alert" (15-minute intervals)
   - "Run Dashboard Tables" (daily at 9:00 AM)
   - "Setup Triggers" (one-time setup)

### 4. Dashboard Setup

1. Access the [Looker Studio Dashboard Template](https://lookerstudio.google.com/reporting/f7a949a1-eafe-4651-8376-9b0bc1dddf54)
2. Create a copy of the dashboard
3. Update data sources to point to your materialized tables:
   - `{project_id}.{dataset_id}.daily_utilization`
   - `{project_id}.{dataset_id}.hourly_utilization`
   - `{project_id}.{dataset_id}.job_usage`
   - `{project_id}.{dataset_id}.job_errors`
   - `{project_id}.{dataset_id}.commitments_timeline`

## Automated Processes

### SQL Execution Flow

1. Apps Script fetches SQL from GitHub repository
2. Variables are replaced with configuration values
3. Queries are executed against BigQuery
4. Results are materialized into tables

### Alert System

The system monitors usage and sends alerts through:
- Email (with PDF attachment)
- Microsoft Teams
- Slack

Alerts are triggered for:
- Daily usage thresholds (1TB, 3TB, 5TB, 10TB, 20TB)
- Error conditions
- Performance issues

### Dashboard Updates

Tables are refreshed daily at 9:00 AM:
- Commitments Timeline
- Daily Utilization
- Hourly Utilization
- Job Usage
- Job Errors

## Maintenance

### Regular Tasks

1. Monitor Apps Script execution logs
2. Review alert thresholds
3. Verify webhook configurations
4. Update SQL queries as needed

### Troubleshooting

1. **Query Failures**
   - Check Apps Script logs
   - Verify BigQuery permissions
   - Confirm SQL syntax

2. **Alert Issues**
   - Verify webhook URLs
   - Check email configuration
   - Review trigger status

## Support Resources

- [BigQuery System Tables Documentation](https://cloud.google.com/bigquery/docs/information-schema-intro)
- [Apps Script Documentation](https://developers.google.com/apps-script)
- [Looker Studio Documentation](https://support.google.com/looker-studio)

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.