/**
 * Configuration for BigQuery setup
 */
const CONFIG = {
  projectId: 'local-incline-341518',
  datasetId: 'bigquery_usage',
  location: 'eu',
  serviceAccountEmail: 'gpt-as-dataanalyst@local-incline-341518.iam.gserviceaccount.com'
};

/**
 * SQL files and their schedules
 */
const SCHEDULED_QUERIES = [
  {
    name: 'Daily Usage',
    schedule: 'every 24 hours',
    fileName: 'daily_usage.sql'
  },
  {
    name: 'TB Billed Hourly',
    schedule: 'every 1 hour',
    fileName: 'tb_billed_hourly.sql'
  },
  {
    name: 'Average Slot Usage',
    schedule: 'every 24 hours',
    fileName: 'avg_slot_usage.sql'
  },
  {
    name: 'BigQuery Daily Usage Alert',
    schedule: 'every 15 minutes',
    fileName: 'bigquery_daily_usage_alert.sql'
  },
  {
    name: 'Most Used Tables',
    schedule: 'every 24 hours',
    fileName: 'most_used_tables.sql'
  },
  {
    name: 'Scheduled Query Errors',
    schedule: 'every 24 hours',
    fileName: 'scheduled_query_errors.sql'
  }
];

/**
 * Creates a BigQuery dataset if it doesn't exist
 */
function createDataset() {
  const resource = {
    datasetReference: {
      datasetId: CONFIG.datasetId,
      projectId: CONFIG.projectId
    },
    location: CONFIG.location,
    defaultPartitionExpirationMs: 60 * 24 * 60 * 60 * 1000  // 60 days
  };
  
  try {
    const response = UrlFetchApp.fetch(
      `https://bigquery.googleapis.com/bigquery/v2/projects/${CONFIG.projectId}/datasets`,
      {
        method: 'post',
        contentType: 'application/json',
        payload: JSON.stringify(resource),
        headers: {
          'Authorization': 'Bearer ' + ScriptApp.getOAuthToken()
        }
      }
    );
    
    Logger.log('Dataset created successfully');
    return JSON.parse(response.getContentText());
  } catch (e) {
    if (e.toString().includes('Already Exists')) {
      Logger.log('Dataset already exists');
      return null;
    }
    throw e;
  }
}

/**
 * Creates or updates a scheduled query
 */
function createScheduledQuery(queryConfig) {
  const sqlContent = DriveApp.getFilesByName(queryConfig.fileName).next().getBlob().getDataAsString();
  
  // Replace variables in the query
  const query = sqlContent
    .replace(/\${PROJECT_ID}/g, CONFIG.projectId)
    .replace(/\${DATASET_ID}/g, CONFIG.datasetId)
    .replace(/\${REGION}/g, CONFIG.location);
  
  const transferConfig = {
    displayName: `Scheduled Query - ${queryConfig.name}`,
    dataSourceId: 'scheduled_query',
    destinationDatasetId: CONFIG.datasetId,
    params: {
      query: query,
      destination_table_name_template: queryConfig.fileName.replace('.sql', ''),
      write_disposition: 'WRITE_TRUNCATE'
    },
    schedule: queryConfig.schedule,
    dataRefreshWindowDays: 1,
    serviceAccountName: CONFIG.serviceAccountEmail
  };
  
  try {
    // Check if config already exists
    const existingConfigs = listScheduledQueries();
    const existingConfig = existingConfigs.find(config => 
      config.displayName === transferConfig.displayName
    );
    
    if (existingConfig) {
      // Update existing config
      const response = UrlFetchApp.fetch(
        `https://bigquerydatatransfer.googleapis.com/v1/${existingConfig.name}`,
        {
          method: 'patch',
          contentType: 'application/json',
          payload: JSON.stringify(transferConfig),
          headers: {
            'Authorization': 'Bearer ' + ScriptApp.getOAuthToken()
          },
          muteHttpExceptions: true
        }
      );
      Logger.log(`Updated scheduled query: ${queryConfig.name}`);
      return JSON.parse(response.getContentText());
    } else {
      // Create new config
      const response = UrlFetchApp.fetch(
        `https://bigquerydatatransfer.googleapis.com/v1/projects/${CONFIG.projectId}/locations/${CONFIG.location}/transferConfigs`,
        {
          method: 'post',
          contentType: 'application/json',
          payload: JSON.stringify(transferConfig),
          headers: {
            'Authorization': 'Bearer ' + ScriptApp.getOAuthToken()
          }
        }
      );
      Logger.log(`Created scheduled query: ${queryConfig.name}`);
      return JSON.parse(response.getContentText());
    }
  } catch (e) {
    Logger.log(`Error with scheduled query ${queryConfig.name}: ${e.toString()}`);
    throw e;
  }
}

/**
 * Lists existing scheduled queries
 */
function listScheduledQueries() {
  try {
    const response = UrlFetchApp.fetch(
      `https://bigquerydatatransfer.googleapis.com/v1/projects/${CONFIG.projectId}/locations/${CONFIG.location}/transferConfigs`,
      {
        method: 'get',
        headers: {
          'Authorization': 'Bearer ' + ScriptApp.getOAuthToken()
        }
      }
    );
    
    const result = JSON.parse(response.getContentText());
    return result.transferConfigs || [];
  } catch (e) {
    Logger.log(`Error listing scheduled queries: ${e.toString()}`);
    return [];
  }
}

/**
 * Main function to set up everything
 */
function setupBigQuery() {
  // Create dataset
  createDataset();
  
  // Create scheduled queries
  SCHEDULED_QUERIES.forEach(queryConfig => {
    try {
      createScheduledQuery(queryConfig);
    } catch (e) {
      Logger.log(`Error processing ${queryConfig.name}: ${e.toString()}`);
    }
  });
}

/**
 * Creates a menu item to run the setup
 */
function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('BigQuery Setup')
    .addItem('Setup Dataset and Queries', 'setupBigQuery')
    .addToUi();
} 