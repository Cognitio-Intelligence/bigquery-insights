function sendAlerts() {
  const spreadsheetId = 'YOUR_SPREADSHEET_ID';
  const sheet = SpreadsheetApp.openById(spreadsheetId).getActiveSheet();
  const data = sheet.getDataRange().getValues();
  
  // Check for alert conditions
  for (let i = 1; i < data.length; i++) {
    const [date, dau, revenue] = data[i];
    if (dau < 1000 || revenue < 10000) {
      sendTeamsAlert(`Alert: Low performance on ${date}. DAU: ${dau}, Revenue: ${revenue}`);
      sendSlackAlert(`Alert: Low performance on ${date}. DAU: ${dau}, Revenue: ${revenue}`);
    }
  }
}

function sendTeamsAlert(message) {
  const teamsWebhookUrl = 'YOUR_TEAMS_WEBHOOK_URL';
  const payload = JSON.stringify({ text: message });
  
  UrlFetchApp.fetch(teamsWebhookUrl, {
    method: 'post',
    contentType: 'application/json',
    payload: payload
  });
}

function sendSlackAlert(message) {
  const slackWebhookUrl = 'YOUR_SLACK_WEBHOOK_URL';
  const payload = JSON.stringify({ text: message });
  
  UrlFetchApp.fetch(slackWebhookUrl, {
    method: 'post',
    contentType: 'application/json',
    payload: payload
  });
}

function createTrigger() {
  ScriptApp.newTrigger('sendAlerts')
    .timeBased()
    .everyHours(1)
    .create();
}