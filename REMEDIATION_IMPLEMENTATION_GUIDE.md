# ATM Simulator – Remediation Implementation Report

Generated from latest Sonar scan (`atm_1`) and dependency analysis.

## 1) Current Risk Snapshot

- Code Smells: **152**
- Duplicated Lines Density: **22.3%**
- Security Hotspots: **26**
- Bugs: **2**
- Complexity: **140**
- Cognitive Complexity: **186**
- Debt ratio: **2.2%**

## 2) Remediation Strategy (Practical Implementation)

### Phase A – Security & Data Access (Highest Priority)

Objective: reduce exploit risk and hotspot count.

Implementation actions:

1. Replace dynamic SQL concatenation with `PreparedStatement` in all transaction/auth flows.
2. Add centralized input validation (card number, PIN, amount, SSN, date fields).
3. Add consistent exception handling and user-safe error messages.
4. Add basic audit logging for authentication and money movement actions.

Target outcomes:

- Security hotspots significantly reduced.
- Lower chance of injection and malformed-input failures.

### Phase B – Duplication Reduction

Objective: reduce 22.3% duplication and improve maintainability.

Implementation actions:

1. Extract reusable dialog/alert helpers.
2. Extract common transaction flow (PIN validation, balance fetch, update).
3. Consolidate repeated UI state toggles into helper methods.
4. Create small service methods to share logic across `Deposit`, `Withdraw`, `FastCash`.

Target outcomes:

- Duplicated lines density reduced.
- Smaller methods and lower cognitive load.

### Phase C – Dependency & Design Refactor

Objective: break cycles and reduce God-service pressure.

Implementation actions:

1. Split `Transactions` responsibilities (menu routing vs operation execution).
2. Introduce service classes (`AccountService`, `TransactionService`, `AuthService`).
3. Move DB logic out of UI classes.
4. Replace direct screen-to-screen construction chains with a navigation controller.

Target outcomes:

- Fan-out of `Transactions` drops below 6.
- Fewer class cycles and lower instability in UI classes.

### Phase D – Quality Guardrails

Objective: prevent recurrence.

Implementation actions:

1. Add unit tests for validators and transaction calculations.
2. Add integration tests for DB operations using test schema.
3. Add CI step to run Sonar scan on each PR.
4. Set quality gate policy to fail on new security hotspots or duplicated code increases.

## 3) Implementation Backlog (Actionable)

| Priority | Task | Effort | Owner |
|---|---|---:|---|
| P0 | Parameterize all SQL queries | 2–3 days | Backend |
| P0 | Validate all user inputs centrally | 1–2 days | Backend |
| P1 | Refactor repeated transaction logic | 2 days | Backend |
| P1 | Extract reusable UI/dialog helpers | 1–2 days | App/UI |
| P1 | Split `Transactions` orchestration class | 2–3 days | App Architecture |
| P2 | Add unit tests for validators/services | 2–3 days | QA/Dev |
| P2 | Add integration tests (DB paths) | 2 days | QA/Dev |
| P2 | CI + Sonar quality gate enforcement | 1 day | DevOps |

## 4) Metrics-driven Targets

| Metric | Current | 1st Target | 2nd Target |
|---|---:|---:|---:|
| Security Hotspots | 26 | <= 10 | 0–3 |
| Duplicated Lines Density | 22.3% | < 15% | < 10% |
| Cognitive Complexity | 186 | < 150 | < 120 |
| Bugs | 2 | 0 | 0 |
| Fan-out (`Transactions`) | 7 | <= 5 | <= 4 |

## 5) Success Criteria

Remediation is considered successful when:

1. Security hotspots trend down and critical hotspots are resolved.
2. Duplication falls below 10–15% threshold.
3. `Transactions` no longer qualifies as God service.
4. No new bug/vulnerability introduced in subsequent scans.
5. Quality gate remains green under stricter conditions.
