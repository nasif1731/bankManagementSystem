# ATM Simulator - Quick Run Commands

## **FASTEST WAY TO RUN PROJECT**

```powershell
docker compose up -d mysql
docker compose --profile gui-docker up -d
```

Access GUI: **http://localhost:6080/vnc.html**

---

## **SONARQUBE ANALYSIS (WITH TOKEN)**

```powershell
docker run --rm --network host `
-v "${PWD}:/usr/src/mymaven" `
-w /usr/src/mymaven `
maven:3.9-eclipse-temurin-17 /bin/bash -c "
mvn clean verify sonar:sonar -Dsonar.projectKey=atm_1 -Dsonar.projectName='My Awesome ATM' -Dsonar.host.url=http://host.docker.internal:9000 -Dsonar.token=sqa_f894b51fb048cccbbe38720a003f4ad459880719
"
```

View Results: **http://localhost:9000**

---

## **TOKEN**
`sqa_f894b51fb048cccbbe38720a003f4ad459880719`

---

## **CLEANUP**
```powershell
docker compose down -v
docker stop sonarqube sonarqube-postgres
docker rm sonarqube sonarqube-postgres
```
