# ATM Simulator - Viva Command Sheet
## Complete Step-by-Step Guide

---

## **PART 1: PROJECT SETUP WITH DOCKER**

### **Step 1: Build the Docker Image**
```powershell
cd C:\Users\nasif\Downloads\bankManagementSystem
docker build -t atm-simulator .
```

### **Step 2: Start MySQL Database**
```powershell
docker compose up -d mysql
```

**Wait for 10-15 seconds for MySQL to be healthy**

### **Step 3: Run the ATM Application in Docker**

**Option A: Run via Docker Compose (GUI with VNC)**
```powershell
docker compose --profile gui-docker up -d --build
```

Then access GUI at: **http://localhost:6080/vnc.html**

**Option B: Run via Docker Container directly**
```powershell
docker run -d --name atm-app `
  --network bankmanagementystem_atm-network `
  -e DB_HOST=mysql `
  -e DB_USER=root `
  -e DB_PASSWORD=root `
  -e DB_NAME=bank_management_system `
  -p 8080:8080 `
  atm-simulator
```

View logs:
```powershell
docker logs -f atm-app
```

---

## **PART 2: SONARQUBE SETUP WITH DOCKER**

### **Step 4: Start PostgreSQL (for SonarQube Database)**
```powershell
docker run -d --name sonarqube-postgres `
  -e POSTGRES_DB=sonarqube `
  -e POSTGRES_USER=sonar `
  -e POSTGRES_PASSWORD=sonar `
  -p 5432:5432 `
  postgres:15
```

**Wait 10 seconds for PostgreSQL to be ready**

### **Step 5: Start SonarQube Server (Docker)**
```powershell
docker run -d --name sonarqube `
  -e SONAR_JDBC_URL=jdbc:postgresql://sonarqube-postgres:5432/sonarqube `
  -e SONAR_JDBC_USERNAME=sonar `
  -e SONAR_JDBC_PASSWORD=sonar `
  --link sonarqube-postgres:postgres `
  -p 9000:9000 `
  sonarqube:community
```

**Wait 30-60 seconds for SonarQube to initialize**

### **Step 6: Access SonarQube Dashboard**
Open in browser: **http://localhost:9000**
- Username: `admin`
- Password: `admin`

### **Step 7: Create Project (if new)**
1. Click **"Create a local project"**
2. **Project key:** `atm_1`
3. **Project name:** `My Awesome ATM`
4. Click **"Set Up"**

### **Step 8: Generate Analysis Token**
1. Click **profile icon** (top right)
2. Click **"My Account"**
3. Go to **"Security"** tab
4. Click **"Generate Tokens"**
5. Name: `atm-viva-token`
6. Click **"Generate"**
7. **Copy the token** immediately

---

## **PART 3: SONARQUBE ANALYSIS WITH DOCKER**

### **Step 9: Run SonarQube Analysis (Option A - Maven Docker)**
```powershell
docker run --rm --network host `
-v "${PWD}:/usr/src/mymaven" `
-w /usr/src/mymaven `
maven:3.9-eclipse-temurin-17 /bin/bash -c "
mvn clean verify sonar:sonar -Dsonar.projectKey=atm_1 -Dsonar.projectName='My Awesome ATM' -Dsonar.host.url=http://host.docker.internal:9000 -Dsonar.token=YOUR_TOKEN_HERE
"
```

**Replace** `YOUR_TOKEN_HERE` with the token from Step 8

### **Step 9B: Run SonarQube Analysis (Option B - Build locally, analyze with Docker)**
```powershell
# Build project locally first
mvn clean package

# Then run SonarQube analysis with Docker
docker run --rm `
  -v "${PWD}:/sources" `
  sonarsource/sonar-scanner-cli `
  -Dsonar.projectKey=atm_1 `
  -Dsonar.projectName='My Awesome ATM' `
  -Dsonar.sources=./src `
  -Dsonar.host.url=http://host.docker.internal:9000 `
  -Dsonar.token=YOUR_TOKEN_HERE
```

**Wait for 2-3 minutes for analysis to complete**

---

## **PART 4: VIEW RESULTS**

### **Step 10: View Analysis Results**
1. Go to **http://localhost:9000**
2. Click **"My Awesome ATM"** project
3. View metrics:
   - **Code Smells**
   - **Bugs**
   - **Vulnerabilities**
   - **Code Duplication**
   - **Lines of Code**
   - **Complexity**
   - **Security Rating**

### **Step 11: View Application (if running in Docker)**
- **GUI via VNC:** http://localhost:6080/vnc.html
- **Logs:** `docker logs atm-app` or `docker logs atm-gui`

---

## **PART 5: EXPORT REPORTS**

### **Step 12: Export Metrics to JSON**
```powershell
$projectKey = "atm_1"
$sonarUrl = "http://localhost:9000"
$token = "YOUR_TOKEN_HERE"

# Get metrics
$metrics = curl -s -u "${token}:" "$sonarUrl/api/measures/component?component=$projectKey&metricKeys=lines,ncloc,complexity,duplicated_lines_density,test_success_density,coverage,code_smells,bugs,vulnerabilities,security_rating,reliability_rating"

$metrics | Out-File -Encoding UTF8 "sonarqube_metrics.json"
Write-Host "✓ Metrics saved to sonarqube_metrics.json"
Get-Content sonarqube_metrics.json | ConvertFrom-Json | ConvertTo-Json -Depth 10
```

### **Step 13: Export Issues to JSON**
```powershell
$projectKey = "atm_1"
$sonarUrl = "http://localhost:9000"
$token = "YOUR_TOKEN_HERE"

# Get issues
$issues = curl -s -u "${token}:" "$sonarUrl/api/issues/search?componentKeys=$projectKey&ps=500"

$issues | Out-File -Encoding UTF8 "sonarqube_issues.json"
Write-Host "✓ Issues saved to sonarqube_issues.json"
Get-Content sonarqube_issues.json | ConvertFrom-Json | ConvertTo-Json -Depth 10
```

---

## **CLEANUP COMMANDS (After Viva)**

### **Stop All Docker Containers**
```powershell
# Stop and remove all containers
docker compose down -v

# Stop SonarQube and PostgreSQL
docker stop sonarqube sonarqube-postgres
docker rm sonarqube sonarqube-postgres

# Stop ATM app (if running separately)
docker stop atm-app
docker rm atm-app

# View running containers
docker ps
```

---

## **QUICK REFERENCE TABLE**

| Step | Action | Command |
|------|--------|---------|
| 1 | Build Docker Image | `docker build -t atm-simulator .` |
| 2 | Start MySQL | `docker compose up -d mysql` |
| 3 | Run ATM (Docker Compose) | `docker compose --profile gui-docker up -d --build` |
| 3B | Run ATM (Docker CLI) | `docker run -d --name atm-app ...` |
| 4 | Start PostgreSQL | `docker run -d --name sonarqube-postgres ...` |
| 5 | Start SonarQube | `docker run -d --name sonarqube ...` |
| 6 | Open SonarQube | `http://localhost:9000` |
| 7-8 | Get Token | Dashboard → My Account → Security → Generate Tokens |
| 9 | Analyze (Maven) | `docker run --rm --network host maven:3.9 ...` |
| 9B | Analyze (SonarQube Scanner) | `docker run --rm sonarsource/sonar-scanner-cli ...` |
| 10 | View Results | `http://localhost:9000/dashboard` |
| 11 | View GUI (VNC) | `http://localhost:6080/vnc.html` |
| 12-13 | Export JSON Reports | `curl -s -u token: http://localhost:9000/api/...` |

---

## **KEY INFORMATION FOR VIVA**

**Project Details:**
- **Name:** ATM Simulator / Bank Management System
- **Language:** Java
- **Framework:** Swing GUI
- **Build Tool:** Maven
- **Containerization:** Docker & Docker Compose
- **Project Key:** `atm_1`

**Docker Images Used:**
- `openjdk:11` or `maven:3.9-eclipse-temurin-17` (Application)
- `mysql:8.0` (Database)
- `postgres:15` (SonarQube Database)
- `sonarqube:community` (Code Analysis)

**Key Ports:**
- **ATM App:** 8080
- **SonarQube:** 9000
- **MySQL:** 3306
- **PostgreSQL:** 5432
- **VNC GUI:** 6080, 5900

**Credentials:**
- **SonarQube Admin:** admin / admin
- **MySQL Root:** root / root
- **Database:** bank_management_system
- **PostgreSQL User:** sonar / sonar

**Useful Docker Commands:**
```powershell
# List running containers
docker ps

# View logs
docker logs <container_name>

# Stop all containers
docker stop $(docker ps -aq)

# Remove all containers
docker rm $(docker ps -aq)

# View Docker images
docker images

# Remove image
docker rmi <image_name>
```

---

## **TROUBLESHOOTING**

**Problem:** Port 9000 already in use
```powershell
docker ps  # Find sonarqube container ID
docker stop <container_id>
docker rm sonarqube
```

**Problem:** MySQL not healthy
```powershell
docker logs atm-mysql
docker compose down -v
docker compose up -d mysql
```

**Problem:** SonarQube analysis failed
- Check token is correct
- Ensure SonarQube is running (http://localhost:9000)
- Check firewall settings

---

---

## **COMPLETE DOCKER EXECUTION FLOW (Quick Start)**

Copy and run these commands in sequence:

```powershell
# Step 1: Build Docker image
docker build -t atm-simulator .

# Step 2: Start MySQL
docker compose up -d mysql
Start-Sleep -Seconds 15

# Step 3: Start PostgreSQL (for SonarQube)
docker run -d --name sonarqube-postgres `
  -e POSTGRES_DB=sonarqube `
  -e POSTGRES_USER=sonar `
  -e POSTGRES_PASSWORD=sonar `
  -p 5432:5432 `
  postgres:15
Start-Sleep -Seconds 10

# Step 4: Start SonarQube
docker run -d --name sonarqube `
  -e SONAR_JDBC_URL=jdbc:postgresql://sonarqube-postgres:5432/sonarqube `
  -e SONAR_JDBC_USERNAME=sonar `
  -e SONAR_JDBC_PASSWORD=sonar `
  --link sonarqube-postgres:postgres `
  -p 9000:9000 `
  sonarqube:community
Start-Sleep -Seconds 30

# Step 5: Start ATM App (Option A - Docker Compose with VNC GUI)
docker compose --profile gui-docker up -d --build

# Or Step 5B: Start ATM App (Option B - Docker CLI)
# docker run -d --name atm-app --network bankmanagementystem_atm-network -e DB_HOST=mysql -e DB_USER=root -e DB_PASSWORD=root -e DB_NAME=bank_management_system -p 8080:8080 atm-simulator

# Step 6: Create SonarQube project and token (manual - do in browser)
# 1. Go to http://localhost:9000
# 2. Create project: key=atm_1, name='My Awesome ATM'
# 3. Generate token (copy it)

# Step 7: Run analysis (replace TOKEN with your actual token)
$token = "YOUR_TOKEN_HERE"
docker run --rm --network host `
-v "${PWD}:/usr/src/mymaven" `
-w /usr/src/mymaven `
maven:3.9-eclipse-temurin-17 /bin/bash -c "
mvn clean verify sonar:sonar -Dsonar.projectKey=atm_1 -Dsonar.projectName='My Awesome ATM' -Dsonar.host.url=http://host.docker.internal:9000 -Dsonar.token=$token
"

# Step 8: View results at http://localhost:9000
```

---
