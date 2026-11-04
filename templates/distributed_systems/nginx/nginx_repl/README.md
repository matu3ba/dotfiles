# nginx container repl and test repl

```bash
# shell 1 repl (without and with logs) + regular start (using read-only file mount)
pushd ./templates/distributed_systems/nginx/nginx_repl/
docker compose --ansi=never --progress=plain -f compose.yaml up --watch --abort-on-container-failure
docker compose --ansi=never --progress=plain -f compose.yaml watch
docker compose --ansi=never --progress=plain -f compose.yaml down -v
docker compose --ansi=never --progress=plain -f compose.yaml up --abort-on-container-failure
docker compose -f compose.yaml logs --follow
# shell2: repl + regular test commands
pushd ./templates/distributed_systems/nginx/nginx_repl/
find . \( -name "*.conf" -o -name "*.sh" \) | entr sh ./test.sh
./test.sh
```
