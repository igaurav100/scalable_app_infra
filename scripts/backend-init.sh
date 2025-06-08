#!/bin/bash

# Install Node.js and sample app
apt-get update
apt-get install -y nodejs npm

# Create simple HTTP server
mkdir -p /opt/app
cat > /opt/app/server.js <<EOF
const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello from backend!\n');
});

server.listen(80, () => {
  console.log('Server running on port 80');
});
EOF

# Start the server
node /opt/app/server.js &