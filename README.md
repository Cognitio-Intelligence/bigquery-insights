# bigquery-insights

This project sets up scheduled queries, sends alerts via AppScript, and provides a dashboard template for insights.

## Installation

1. Clone this repository
2. Update the `config.yaml` file with your project details
3. Run `setup.sh` to configure the project:
   ```
   sh setup.sh
   ```
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