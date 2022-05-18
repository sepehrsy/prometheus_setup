# prometheus_setup

#### first we must prepare docker-compse and /prometheus/config directory in our host
```
cp docker-compose.yml /root/
mkdir /prometheus/config
chown -R  nobody: /prometheus
```
#### after that we must prepare  config files of (prometheus.rules.yml - prometheus.yml - alertmanager.yml) in /prometheus/config directory
```
cp prometheus.rules.yml prometheus.yml alertmanager.yml /prometheus/config/
```
#### if you use nginx web serever
```
cp prom.example.com /etc/nginx/conf.d/
```
#### for basic authentication create admin user
```
htpasswd -c /etc/nginx/htpasswd - admin
```
#### final step:
```
cd /root
docker-compose up -d
```
#### URLS:
##### prom: http://prom.example.com:9090/ 
##### node exporter: http://prom.example.com:9100/metrics 

#### any change on prometheus.yml file could reload by:
```
curl -i -XPOST localhost:9090/-/reload
```
