#!/bin/bash

# Install NGINX
apt-get update
apt-get install -y nginx

# Configure NGINX to proxy to backend
cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://${backend_address};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Restart NGINX
systemctl restart nginx