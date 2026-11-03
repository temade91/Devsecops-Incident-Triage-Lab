const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Health checks
app.get('/healthz', (req, res) => {
  res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.get('/livez', (req, res) => {
  res.status(200).send('OK');
});

app.get('/', (req, res) => {
  res.json({
    service: 'devsecops-incident-triage-lab',
    status: 'operational',
    environment: process.env.NODE_ENV || 'production'
  });
});

app.listen(PORT, () => {
  console.log(`Server running securely on port ${PORT}`);
});