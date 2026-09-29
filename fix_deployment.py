import os

def write_file(path, content):
    d = os.path.dirname(path)
    if d:
        os.makedirs(d, exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content.strip() + "\n")

# 1. polar-ops-backend/Dockerfile
write_file("polar-ops-backend/Dockerfile", """FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
""")

# 2. polar_ops_web/Dockerfile
write_file("polar_ops_web/Dockerfile", """FROM nginx:alpine
COPY build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
""")

# 3. docker-compose.yml
write_file("docker-compose.yml", """services:
  backend:
    build:
      context: ./polar-ops-backend
      dockerfile: Dockerfile
    container_name: himadri-setu-backend
    ports:
      - "8080:8080"
    environment:
      - JWT_SECRET=himadri-setu-secret-key-2026
    networks:
      - himadri-network
    healthcheck:
      test: ["CMD", "wget", "-q", "--tries=1", "--spider", "http://localhost:8080/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
  
  flutter-web:
    build:
      context: ./polar_ops_web
      dockerfile: Dockerfile
    container_name: himadri-setu-frontend
    ports:
      - "80:80"
    depends_on:
      backend:
        condition: service_healthy
    networks:
      - himadri-network

networks:
  himadri-network:
    driver: bridge
""")

# 4. polar-ops-backend/.dockerignore
write_file("polar-ops-backend/.dockerignore", """target/
*.log
.mvn/
""")

# 5. polar_ops_web/.dockerignore
write_file("polar_ops_web/.dockerignore", """build/
.dart_tool/
.packages/
*.log
""")

# 6. HealthController.java
write_file("polar-ops-backend/src/main/java/in/gov/moes/ncpor/polarops/controller/HealthController.java", """package in.gov.moes.ncpor.polarops.controller;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {
    @GetMapping("/api/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("UP");
    }
    @GetMapping("/")
    public ResponseEntity<String> root() {
        return ResponseEntity.ok("HIMADRI-SETU Backend is running!");
    }
}
""")

# 7. start-himadri.bat
write_file("start-himadri.bat", """@echo off
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
""")

# 8. stop-himadri.bat
write_file("stop-himadri.bat", """@echo off
docker compose stop
docker compose rm -f
echo All services stopped!
pause
""")

print("Successfully fixed deployment configuration.")
