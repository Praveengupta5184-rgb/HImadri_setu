@echo off
docker compose stop
docker compose rm -f
echo All services stopped!
pause
