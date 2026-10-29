# IT Operations & Run Guide: Multi-Agent Fleet Triage

**Audience:** L2/L3 IT Operations, Cloud Platform Engineers, SecOps Incident Responders  
**System:** Governed 3-Agent Supply-Chain Fleet (`enterprise-agent-identity-graph`)  

---

## 1. Architecture Summary
The system executes across three bounded worker identities:
* `App-Agent-SlaIngest` (Document & Contract Ingestion)
* `App-Agent-CapacityEval` (Fabric Direct Lake Grounding)
* `App-Agent-ErpStager` (Cosmos DB Memory & Proposal Staging)

---

## 2. Distributed Tracing & Error Attribution
Every inter-agent request carries a W3C `traceparent` header.

### Diagnostic Step: Pinpoint Failed Agent Handoff
Execute inside **Azure Monitor / Log Analytics**:
```kql
AppDependencies
| where AppRoleName in ("App-Agent-SlaIngest", "App-Agent-CapacityEval", "App-Agent-ErpStager")
| project Timestamp = TimeGenerated, OperationId, Agent = AppRoleName, Target, DurationMs, ResultCode
| order by Timestamp asc
```
* **HTTP 403 Forbidden on Agent 1**: Expected if Agent 1 attempts to query relational data. Check if caller injected unauthorized prompt parameters.
* **DurationMs > 800ms on Agent 2**: Indicates Fabric Direct Lake fallback to DirectQuery. Check if Delta tables require optimization (`OPTIMIZE` / `VACUUM`).

---

## 3. Circuit-Breaker Triage
If multi-agent negotiation exceeds 12 turns, execution is automatically frozen to prevent token runaway.
```kql
AppEvents
| where Name == "AgentTurnExecution"
| extend SessionId = tostring(customDimensions.sessionId)
| summarize TurnCount = count() by SessionId, bin(TimeGenerated, 5m)
| where TurnCount >= 12
```
**Remediation:** Inspect `SessionId` in Azure Cosmos DB Decision Memory (`case_records` container) to see the conflicting parameters between supplier penalty terms and plant availability.

---

## 4. Decommissioning an Agent
Run the automated offboarding script:
```powershell
./identity/Revoke-AgentIdentity.ps1 -AgentDisplayName "App-Agent-SlaIngest"
```
