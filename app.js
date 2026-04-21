const fs = require('fs');
const express = require('express');

const app = express();

// Read optional config file mounted from a ConfigMap.
let config = {};
try {
  const rawConfig = fs.readFileSync('/app/config/config.json', 'utf-8');
  config = JSON.parse(rawConfig);
} catch (err) {
  console.log('No config file found, using defaults');
}

// Read secrets from environment variables.
const dbUser = process.env.DB_USER || 'default_user';
const dbPassword = process.env.DB_PASSWORD || 'default_password';
const port = Number(process.env.PORT || 3000);

app.get('/', (req, res) => {
  res.json({
    message: config.message || 'Hello World',
    database: {
      user: dbUser,
      password: dbPassword ? '******' : 'not set'
    }
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.get('/healthz', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.listen(port, () => {
  console.log(`Server started on port ${port}`);
});
