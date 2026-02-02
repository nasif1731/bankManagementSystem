# Software Re-Engineering Assignment 1

**Student Name:** Nehal Asif & Ibrahim Khan  
**Course:** Software Re-Engineering  
**Project:** Code Analyis of ATM Simulator (Bank Management System)

---

## 🚀 Assignment Instructions (Docker & SonarQube)

### 1. Project Overview
This repository contains the containerized version of a Java-based ATM Simulator.  
The project includes a `Dockerfile` for consistent deployment and has been analyzed using **SonarQube** for software quality assessment as part of the Software Re-Engineering assignment.

---

### 2. How to Run with Docker

**Prerequisite:** Docker Desktop must be installed and running.

#### Step 1: Build the Docker Image
```bash
docker build -t atm-simulator .
```

#### Step 2: Run the Docker Container
```bash
docker run --name atm-app atm-simulator
```

---

### 3. SonarQube Analysis Steps

#### Step 1: Start SonarQube Server
```bash
docker run -d --name sonarqube -p 9000:9000 sonarqube:community
```

Access SonarQube at:  
`http://localhost:9000`

(Default credentials: `admin / admin`)

---

#### Step 2: Run SonarQube Scanner
> Use this command in **PowerShell** (no local Maven installation required):

```powershell
docker run --rm --network host `
-v "${PWD}:/usr/src/mymaven" `
-w /usr/src/mymaven `
maven:3.9-eclipse-temurin-17 /bin/bash -c "
mvn clean verify org.sonarsource.scanner.maven:sonar -Dsonar.projectKey=atm_simulator -Dsonar.projectName='ATM Simulator' -Dsonar.host.url=http://host.docker.internal:9000 -Dsonar.token=YOUR_TOKEN_HERE
"
```

⚠️ Replace `YOUR_TOKEN_HERE` with your SonarQube authentication token.

---

### 4. SonarQube Analysis Results

- **Code Smells:** 152  
- **Code Duplication:** 22.5%  
- **Security Rating:** E (Critical)  

These results highlight areas for refactoring, improved maintainability, and security hardening.

---

<details>
<summary><strong>🔻 Click here to view Original Project Documentation 🔻</strong></summary>

## Bank Management System

This section contains the **original documentation** from the source repository.

<!-- Bank Management System -->
# ATM Simulator (Bank Management System)

<!-- ABOUT THE PROJECT -->
## About ATM Simulator

The "ATM Simulator" project is a model for Bank System Management. It enables the bank's customers to perform various banking tasks and transactions like creating an account with the bank, requesting and accessing various services and facilities offered by the bank, deposit/withdraw cash from their accounts, etc. The customers can access this banks application also for viewing their account balance, getting mini statements and performing transactions as per their requirement. Simply put, this project converts the brick-and-mortar structure of traditional banking system into a click and portal model, there by giving the concept of virtual banking a real shape in true sense.

The inspiration for this ATM Simulator project stems from the basic need of having an e-financial application in todays fast paced online world, for customers in banking environment. This project is meant to nurture the needs of an end banking user by providing them various ways to perform all banking tasks at the disposal of a few button clicks. Also, to easily enable functionalities which are otherwise not provided under a conventional banking project. This project has been developed to make banking processes easy and quick, which is a shortcoming of the traditional system.

<!-- How to run ATM Simulator -->
## How to install and run ATM Simulator

Follow the steps to run ATM Simulator.

*Prerequisite: Install Java and MySQL on your server.

1. Fork the Project / Download the source code as a zip file.
2. Extract the code on your server.
2. Open MySQL Workbench and run the ATM_Simulator.sql file from sql folder.
3. Navigate to and open the "\src\atm\simulator\system\Conn.java" class and update details for your MySQL server, username and password.
4. Now run the "\src\atm\simulator\system\Login.java".
5. You could also create a MySQL user with credentials as username:"root" & password:"root", run the ATM_Simulator.sql file from sql folder and then directly run the /executable/ATM_Simulator.jar file.

<!-- How to use ATM Simulator -->
## How to use ATM Simulator

Follow these steps to use ATM Simulator.

1. When accessing first time, click sign up, fill up the form to create an account.
2. Now Login with your cardnumber and pin to access the ATM Simulator GUI.
3. You have the option of depositing money, withdrawing money or withdrawing using fast cash option.
4. You also have the option of changing your PIN and checking your account balance.
5. You can also request a mini statement for your account.
6. The mini statement shows your name, your masked card number, you account balance and your last 10 transactions.

<!-- Screenshots of ATM Simulator -->
### Screenshots of ATM Simulator
<img src="/screenshots/1.jpg"
     style="display: inline-block; margin: 0 auto; width:600px; height:400px;">
<img src="/screenshots/2.jpg"
     style="display: inline-block; margin: 0 auto; width:800px; height:600px;">
<img src="/screenshots/4.jpg"
     style="display: inline-block; margin: 0 auto; width:800px; height:600px;">     
<img src="/screenshots/5.jpg"
     style="display: inline-block; margin: 0 auto; width:800px; height:600px;">
<img src="/screenshots/6.jpg"
     style="display: inline-block; margin: 0 auto; width:800px; height:450px;">
<img src="/screenshots/3.jpg"
     style="display: inline-block; margin: 0 auto; width:800px; height:700px;">
<!-- CONTRIBUTING -->
## Contributing

If you have to add a feature, please fork the repo and create a pull request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/Feature`)
3. Commit your Changes (`git commit -m 'Adding Feature'`)
4. Push to the Branch (`git push origin feature/Feature`)
5. Open a Pull Request

<p align="right">(<a href="#top">back to top</a>)</p>


</details>



