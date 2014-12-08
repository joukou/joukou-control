server {
  listen 8080;
  server_name control.joukou.com;

  location / {
    root /var/www;
  }

  error_page 500 502 503 504 /50x.html;
  location = /50x.html {
    root /usr/share/nginx/html;
  }
}
