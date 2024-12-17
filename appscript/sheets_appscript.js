function getConfig() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Config');
  if (!sheet) throw new Error('Config sheet not found.');

  return {
    PROJECT_ID: sheet.getRange('B1').getValue(),
    DATASET_ID: sheet.getRange('B2').getValue(),
    LOCATION: sheet.getRange('B3').getValue()
  };
}

function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('BigQuery Usage 👀')
    .addItem('Run BigQuery Daily Usage Alert', 'runBigQueryDailyUsageAlert')
    .addItem('Run Dashboard Tables', 'runDailyBigQueryScripts')
    .addItem('Setup Triggers', 'createTriggers')
    .addToUi();
}


function createTriggers() {
  let logMessage = "Starting trigger setup...\n";

  try {
    deleteExistingTriggers();
    logMessage += "Existing triggers deleted.\n";

    ScriptApp.newTrigger('runBigQueryDailyUsageAlert')
      .timeBased()
      .everyMinutes(15)
      .create();
    logMessage += 'Trigger for "bigquery_daily_usage_alert" created.\n';

    ScriptApp.newTrigger('runDailyBigQueryScripts')
      .timeBased()
      .everyDays(1)
      .atHour(9)
      .create();
    logMessage += 'Daily BigQuery script trigger created for 9:00 AM.\n';
    
    showLogs(logMessage);
  } catch (error) {
    logMessage += `Error creating triggers: ${error.message}\n`;
    showLogs(logMessage);
  }
}


function showLogs(message) {
  const ui = SpreadsheetApp.getUi();
  ui.showModelessDialog(
    HtmlService.createHtmlOutput(`<div style="font-family: Arial, sans-serif; font-size: 14px;">
      <h3>Script Logs</h3>
      <pre>${message}</pre>
    </div>`).setWidth(400).setHeight(300),
    "Execution Logs"
  );
}

// Deletes all existing triggers
function deleteExistingTriggers() {
  const triggers = ScriptApp.getProjectTriggers();
  triggers.forEach((trigger) => {
    ScriptApp.deleteTrigger(trigger);
  });
}

function runBigQueryDailyUsageAlert() {
  let logMessage = "Starting BigQuery Daily Usage Alert...\n";

  try {
    const { PROJECT_ID, DATASET_ID, LOCATION } = getConfig(); 
    logMessage += "Fetched configuration successfully.\n";
    showLogs(logMessage);

    const url = "https://raw.githubusercontent.com/Cognitio-Intelligence/bigquery-insights/main/sql/bigquery_daily_usage_alert.sql";
    logMessage += "Fetching SQL file...\n";
    showLogs(logMessage);

    const sql = fetchSQLFromGitHub(url);
    if (sql) {
      logMessage += "SQL file fetched successfully. Processing variables...\n";
      showLogs(logMessage);

      const processedSQL = replaceVariablesInSQL(sql);
      logMessage += "Variables replaced. Executing query...\n";
      showLogs(logMessage);

      runBigQueryQuery(processedSQL);
      logMessage += "Query executed successfully. Saving results...\n";
      showLogs(logMessage);

      saveResultsAndNotify();
      logMessage += "Results saved and notification sent.\n";
      showLogs(logMessage);
    } else {
      logMessage += "Failed to fetch SQL file.\n";
      showLogs(logMessage);
    }
  } catch (error) {
    logMessage += `Error: ${error.message}\n`;
    showLogs(logMessage);
  }
}

function runDailyBigQueryScripts() {
  let logMessage = "Starting execution of daily BigQuery scripts...\n";

  try {
    const { PROJECT_ID, DATASET_ID, LOCATION } = getConfig(); 
    logMessage += "Fetched configuration successfully.\n";
    showLogs(logMessage);

    const sqlFiles = [
      "https://raw.githubusercontent.com/Cognitio-Intelligence/bigquery-insights/main/sql/commitments_timeline.sql",
      "https://raw.githubusercontent.com/Cognitio-Intelligence/bigquery-insights/main/sql/daily_utilization.sql",
      "https://raw.githubusercontent.com/Cognitio-Intelligence/bigquery-insights/main/sql/hourly_utilization.sql",
      "https://raw.githubusercontent.com/Cognitio-Intelligence/bigquery-insights/main/sql/job_errors.sql",
      "https://raw.githubusercontent.com/Cognitio-Intelligence/bigquery-insights/main/sql/job_usage.sql",
    ];

    sqlFiles.forEach((url, index) => {
      logMessage += `Fetching SQL file ${index + 1} from: ${url}\n`;
      showLogs(logMessage);

      const sql = fetchSQLFromGitHub(url);
      if (sql) {
        logMessage += `SQL file ${index + 1} fetched successfully. Processing variables...\n`;
        showLogs(logMessage);

        const processedSQL = replaceVariablesInSQL(sql);
        logMessage += `Variables replaced for SQL file ${index + 1}. Executing query...\n`;
        showLogs(logMessage);

        runBigQueryQuery(processedSQL);
        logMessage += `Query executed successfully for SQL file ${index + 1}.\n`;
        showLogs(logMessage);
      } else {
        logMessage += `Failed to fetch SQL file ${index + 1}.\n`;
        showLogs(logMessage);
      }
    });

    logMessage += "All daily BigQuery scripts executed successfully.\n";
    showLogs(logMessage);
  } catch (error) {
    logMessage += `Error: ${error.message}\n`;
    showLogs(logMessage);
  }
}


// Fetches the SQL content from GitHub
function fetchSQLFromGitHub(url) {
  try {
    const response = UrlFetchApp.fetch(url);
    if (response.getResponseCode() === 200) {
      return response.getContentText();
    } else {
      console.error("Failed to fetch SQL file:", url);
      return null;
    }
  } catch (e) {
    console.error("Error fetching SQL file:", url, e);
    return null;
  }
}

function replaceVariablesInSQL(sql) {
  const { PROJECT_ID, DATASET_ID,LOCATION } = getConfig(); 
  return sql
    .replace(/\${PROJECT_ID}/g, PROJECT_ID)
    .replace(/\${DATASET_ID}/g, DATASET_ID)
    .replace(/\${LOCATION}/g, LOCATION)
    .replace(/{PROJECT_ID}/g, PROJECT_ID)
    .replace(/{DATASET_ID}/g, DATASET_ID)
    .replace(/{LOCATION}/g, LOCATION);
}

// Executes the SQL query in BigQuery
function runBigQueryQuery(sql) {
  const { PROJECT_ID, DATASET_ID,LOCATION } = getConfig(); 
  const queryRequest = {
    query: sql,
    useLegacySql: false
  };

  try {
    const bigQueryService = BigQuery.Jobs;
    const queryResults = bigQueryService.query(queryRequest, PROJECT_ID);

    // Logs the results of the query
    if (queryResults.jobComplete) {
      console.log("Query executed successfully:", queryResults.rows || "No rows returned");
    } else {
      console.error("Query execution failed:", queryResults);
    }
  } catch (e) {
    console.error("Error executing query:", e);
  }
}

function fetchColumnNames(projectId, datasetId, tableName) {
  const query = `
    SELECT column_name
    FROM \`${projectId}.${datasetId}.INFORMATION_SCHEMA.COLUMNS\`
    WHERE table_name = '${tableName}'`;

  const queryRequest = {
    query: query,
    useLegacySql: false
  };

  try {
    const bigQueryService = BigQuery.Jobs;
    const queryResults = bigQueryService.query(queryRequest, projectId);

    if (queryResults.jobComplete) {
      const rows = queryResults.rows || [];
      if (rows.length > 0) {
        return rows.map((row) => row.f[0].v); // Extract column names
      } else {
        console.log("No columns found for the table.");
        return [];
      }
    } else {
      console.error("Query did not complete successfully.");
    }
  } catch (e) {
    console.error("Error fetching column names from BigQuery table:", e);
  }
  return [];
}

function saveResultsAndNotify() {
  const { PROJECT_ID, DATASET_ID } = getConfig(); // Fetch configuration values
  const tableName = 'bigquery_daily_usage_alert';
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  let sheet = spreadsheet.getSheetByName('Results');

  // Create the sheet if it doesn't exist
  if (!sheet) {
    sheet = spreadsheet.insertSheet('Results');
  } else {
    sheet.clear(); // Clear the sheet if it already exists
  }

  // Fetch column names
  const headers = fetchColumnNames(PROJECT_ID, DATASET_ID, tableName);

  // Fetch data from the table
  const data = fetchDataFromBigQueryTable(); // Ensure this function fetches rows

  if (headers.length > 0) {
    sheet.appendRow(headers); // Add headers to the sheet

    if (data.length > 0) {
      data.forEach((row) => {
        const rowData = row.f.map((field) => field.v || ''); // Map field values, default to empty string
        sheet.appendRow(rowData);
      });
      console.log("Results saved to Google Sheet.");
    } else {
      console.log("No data to save.");
    }

    // Check columns and send email
    notifyUser(sheet);
  } else {
    console.log("No headers to save.");
  }
}

function notifyUser(sheet) {
  const configSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Config');
  if (!configSheet) throw new Error('Config sheet not found.');

  const recipientEmail = configSheet.getRange('B4').getValue();
  const teamsWebhook = configSheet.getRange('B5').getValue();
  const slackWebhook = configSheet.getRange('B6').getValue();

  const subject = "BigQuery Daily Usage Alert";
  const message = `
    Hello,

    The daily BigQuery usage alert has been generated and saved in the "Results" sheet of the spreadsheet.

    Please check the attached spreadsheet for more details.

    Best regards,
    Your BigQuery Automation Script
  `;

  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  const pdfBlob = spreadsheet.getBlob().setName(`${spreadsheet.getName()}_Results.pdf`);

  // Send Email
  if (recipientEmail) {
    try {
      GmailApp.sendEmail(recipientEmail, subject, message, {
        attachments: [pdfBlob],
      });
      console.log(`Notification sent to ${recipientEmail}`);
    } catch (error) {
      console.error(`Failed to send email to ${recipientEmail}:`, error.message);
    }
  } else {
    console.warn("Recipient email (B4) is not specified. Skipping email notification.");
  }

  // Send to Teams
  if (teamsWebhook) {
    try {
      sendToWebhook(teamsWebhook, {
        text: `*${subject}*\n\n${message.replace(/\n/g, "\n\n")}`,
      });
      console.log("Notification sent to Teams.");
    } catch (error) {
      console.error(`Failed to send message to Teams: ${error.message}`);
    }
  } else {
    console.warn("Teams webhook (B5) is not specified. Skipping Teams notification.");
  }

  // Send to Slack
  if (slackWebhook) {
    try {
      sendToWebhook(slackWebhook, {
        text: `*${subject}*\n\n${message}`,
      });
      console.log("Notification sent to Slack.");
    } catch (error) {
      console.error(`Failed to send message to Slack: ${error.message}`);
    }
  } else {
    console.warn("Slack webhook (B6) is not specified. Skipping Slack notification.");
  }
}

// Helper function to send messages to webhooks
function sendToWebhook(webhookUrl, payload) {
  try {
    const options = {
      method: 'post',
      contentType: 'application/json',
      payload: JSON.stringify(payload),
    };

    const response = UrlFetchApp.fetch(webhookUrl, options);
    if (response.getResponseCode() === 200) {
      console.log("Message sent successfully to webhook.");
    } else {
      console.error(`Failed to send message to webhook: ${response.getContentText()}`);
    }
  } catch (error) {
    console.error(`Error sending message to webhook (${webhookUrl}):`, error.message);
  }
}



function fetchDataFromBigQueryTable() {
  const { PROJECT_ID, DATASET_ID } = getConfig(); // Fetch configuration values
  const tableName = `${PROJECT_ID}.${DATASET_ID}.bigquery_daily_usage_alert`;

  const query = `SELECT * FROM \`${tableName}\` LIMIT 1000`; // Modify the query as needed
  const queryRequest = {
    query: query,
    useLegacySql: false
  };

  try {
    const bigQueryService = BigQuery.Jobs;
    const queryResults = bigQueryService.query(queryRequest, PROJECT_ID);

    if (queryResults.jobComplete) {
      const rows = queryResults.rows || [];
      if (rows.length > 0) {
        rows.forEach((row) => {
          console.log(row); // Process each row as needed
        });
        return rows; // Return data for further processing
      } else {
        console.log("No data found in the table.");
        return [];
      }
    } else {
      console.error("Query did not complete successfully.");
    }
  } catch (e) {
    console.error("Error fetching data from BigQuery table:", e);
  }
}


