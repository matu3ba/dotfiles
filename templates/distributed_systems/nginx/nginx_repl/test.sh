#!/usr/bin/env bash

#set -x
set -euo pipefail

# sleep optimized for WSL, which is slower than Linux; alternatives too complex
sleep 0.5 # wait for docker runtime to pick up file change and flush file write
docker exec -it nginx-k8s nginx -t
docker exec -it nginx-k8s nginx -s reload
sleep 0.1 # wait for nginx to reload

# print resulting nginx config: docker exec nginx-k8s nginx -T
# header only
# curl -I http://127.0.0.1:80/
# curl -I http://127.0.0.1:80/api/health
# content only
# echo "---------------"
# docker compose exec nginx-k8s cat /etc/nginx/nginx.conf
# docker compose exec nginx-k8s cat /etc/nginx/conf.d/default.conf
# header+content
# curl -i http://127.0.0.1:80/
# curl -i http://127.0.0.1:80/api/health
# response headers
# curl -v http://127.0.0.1:80/api/health

# content based debugging
echo "---------------:80/"
curl -s http://127.0.0.1:80/
echo "---------------:8080/health"
curl -s http://127.0.0.1:8080/health
printf "\n"
echo "---------------:80/api/health"
curl -s http://127.0.0.1:80/api/health
printf "\n"
echo "---------------:end"
