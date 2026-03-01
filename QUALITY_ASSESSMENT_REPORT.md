# ATM Simulator – Quality Assessment Report

Made on: March 1, 2026  
Project key: `atm_1`  
Sonar analysis id: `a9066708-114f-4df6-bd12-61dfade77af8`  
Quality Gate: **OK**

## Part 1 – Analysis (20 Marks)

### Step 1: Asset Inventory

| Category | Asset Type | Count | Evidence |
|---|---:|---:|---|
| Source code | Java files (`src/atm/simulator/system`) | 13 | Login, Transactions, Deposit, Withdraw, etc. |
| Source/resources | Total files under `src/` | 15 | Java + icon resources |
| Config files | Build/runtime config | 8 | `pom.xml`, `docker-compose.yml`, `Dockerfile`, `Dockerfile.gui`, `.dockerignore`, `.gitattributes`, entrypoint scripts |
| Database assets | SQL schema/init scripts | 1 | `sql/ATM_Simulator.sql` |
| Documentation | Project docs | 2 | `README.md`, `REMEDIATION_IMPLEMENTATION_GUIDE.md` |
| Libraries | External runtime dependencies | 2 | `mysql-connector-java:8.0.33`, `jcalendar:1.4` |

---

## Part 2 – Quality Assessment Using Tools (25 Marks)

Source: SonarQube API for project `atm_1`.

| Required Metric | Value | Notes |
|---|---:|---|
| Cyclomatic Complexity (CC) | **140** | Sonar `complexity` |
| Cognitive Complexity | **186** | Sonar `cognitive_complexity` |
| Duplications | **22.3%** | Sonar `duplicated_lines_density` |
| Security Hotspots | **26** | Sonar `security_hotspots` |
| Maintainability Index | **Not directly provided by SonarQube** | Sonar equivalent: Maintainability Rating = `sqale_rating` |
| Maintainability Rating (proxy) | **A (1.0)** | Sonar `sqale_rating` |
| Lines of Code (LOC) | **1975** | Sonar `ncloc` |

Additional useful quality indicators:

- Code Smells: **152**
- Bugs: **2**
- Vulnerabilities: **0**
- Reliability Rating: **D (4.0)**
- Security Rating: **A (1.0)**
- Technical Debt (`sqale_index`): **1329 min** (~22.15 hours)
- Debt Ratio (`sqale_debt_ratio`): **2.2%**

---

## Part 3 – Dependency Mapping (20 Marks)

### Class-level Ca, Ce, Instability

Formula:  
\[
I = \frac{Ce}{Ca + Ce}
\]

| Class | Fan-in (Ca) | Fan-out (Ce) | Instability (I) |
|---|---:|---:|---:|
| Conn | 11 | 0 | 0.00 |
| Transactions | 8 | 7 | 0.47 |
| Login | 3 | 3 | 0.50 |
| Deposit | 2 | 2 | 0.50 |
| Withdraw | 2 | 2 | 0.50 |
| FastCash | 1 | 3 | 0.75 |
| CheckBalance | 1 | 2 | 0.67 |
| MiniStatement | 1 | 2 | 0.67 |
| MiniStatementResult | 1 | 3 | 0.75 |
| PinChange | 1 | 3 | 0.75 |
| SignupOne | 1 | 2 | 0.67 |
| SignupTwo | 1 | 2 | 0.67 |
| SignupThree | 1 | 3 | 0.75 |

### Cycle Detection

Detected dependency cycles (class reference level):

1. `Login -> Transactions -> PinChange -> Login`
2. `Login -> SignupOne -> SignupTwo -> SignupThree -> Login`
3. `Transactions -> FastCash -> Withdraw -> Transactions`
4. `Transactions -> MiniStatement -> MiniStatementResult -> Transactions`

### God Service Check (Ce > 5)

- **Detected**: `Transactions` with **Ce = 7** → qualifies as a God-service-like orchestrator.

---

## Part 4 – Technical Debt Identification (15 Marks)

### Case-based Classification

| Case | Intentional / Unintentional | Environmental? | Prudent / Reckless | Deliberate / Inadvertent | Rationale |
|---|---|---|---|---|---|
| **A**: Hard-coded delivery fee in multiple services | Intentional (usually quick implementation) | Mostly non-environmental (internal design choice) | Reckless (spreads change risk) | Deliberate | Creates duplication and high change cost |
| **B**: `OrderService` CC = 35 | Often unintentional (incremental growth) | Non-environmental | Reckless | Inadvertent | Indicates poor decomposition and testability risk |
| **C**: Deprecated external API usage | Initially intentional, later forced by ecosystem | **Environmental** (vendor/platform change) | Prudent if migration planned, reckless if ignored | Inadvertent (if not tracked) | External dependency lifecycle drives this debt |

Project-specific debt observed in this codebase:

- 152 code smells
- 22.3% duplication
- 26 security hotspots
- 2 bugs
- Multiple high-instability UI classes (I >= 0.67)

---

## Part 5 – Technical Debt Measurement (10 Marks)

Using Sonar values:

1) **Total remediation time**  
`sqale_index = 1329 minutes` = **22.15 hours**

2) **Add 20% buffer**  
\[
22.15 \times 1.20 = 26.58 \text{ hours}
\]
Buffered total = **26.58 hours**

3) **Debt Ratio**  
`sqale_debt_ratio = 2.2%`

### Interpretation

- **Healthy**: < 5%
- Moderate: 5% – 15%
- Risky: > 15%

Project result: **2.2% → Healthy (by Sonar debt ratio scale)**.

Note: Even with healthy debt ratio, high duplication (22.3%) and 26 hotspots indicate strong refactoring/security-review needs.

---

## Reflection (Bonus 10 Marks)

### 1) Which debt should be fixed first and why?

Fix **security hotspots and data-access hardening first** (parameterized queries, input validation, auth review), because security issues have the highest impact/risk profile and can invalidate all other quality gains.

Priority order:

1. Security hotspots (26)
2. High duplication (22.3%)
3. God-service decomposition (`Transactions`, Ce=7)
4. Cycle breaking in UI flow

### 2) What was surprising in the analysis?

- Sonar debt ratio is low (**2.2%**) while duplication is very high (**22.3%**).
- Quality Gate is **OK** despite **152 code smells**.
- The dependency graph has multiple cycles in a relatively small codebase (13 classes), increasing maintenance risk.

---

## Data Source Notes

- SonarQube version: `26.2.0.119303`
- CE task status: `SUCCESS`
- Security hotspots detail endpoint required elevated browse privileges, but hotspot count was retrieved through `security_hotspots` measure.
