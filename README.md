Dockerfile Elastic Search
==========================
#### Build
```
# git clone https://github.com/ruo91/docker-elasticsearch /opt/docker-elasticsearch
# docker build --rm -t elasticsearch:source /opt/docker-elasticsearch
```

#### Run
```
root@ruo91:~# docker run -d --name="elasticsearch" -h "elasticsearch" \
-p 9200:9200 -p 9300:9300 elasticsearch:source
```
