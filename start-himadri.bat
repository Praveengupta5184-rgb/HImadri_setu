@echo off
echo Building HIMADRI-SETU...
cd polar-ops-backend
call mvn clean package -DskipTests
cd ..
cd polar_ops_web
call flutter clean
call flutter build web
cd ..
docker compose up -d --build
echo HIMADRI-SETU is running!
echo Backend: http://localhost:8080
echo Flutter Web: http://localhost:80
pause
