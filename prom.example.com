#
server {
    listen       80;
    server_name prom.example.com;
    location / {
	allow private_ip_range;
	deny all;
        return 301 https://$host$request_uri;
        include /etc/nginx/restricted.conf;
    }

    access_log /var/log/nginx/prom_access.log;
    error_log /var/log/nginx/prom_error.log;

}
server {
    listen       443 ssl;
    server_name prom.example.com;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers  on;
    ssl_dhparam          /etc/ssl/certs/dhparam.pem;
    ssl_certificate      /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key  /etc/letsencrypt/live/example.com/privkey.pem;
    ssl_ciphers "EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH EDH+aRSA RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !MEDIUM";
    add_header Strict-Transport-Security max-age=15768000;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_stapling on;
    ssl_stapling_verify on;

    access_log /var/log/nginx/prom_access.log;
    error_log /var/log/nginx/prom_error.log;

    location / {
	auth_basic "";
        auth_basic_user_file /etc/nginx/htpasswd;
	allow private_ip_range;
	deny all;
    	proxy_set_header Host            $host;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    	proxy_set_header X-Forwarded-For $remote_addr;
        proxy_pass http://prom_server_ip:9090;
        client_max_body_size 100M;

	include /etc/nginx/restricted.conf;
    }
}

