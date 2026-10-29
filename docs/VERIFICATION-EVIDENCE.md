# tool authority matrix

Generated: 2026-10-28
Evidence mode: deterministic synthetic local fixture
Live Microsoft service evidence: not collected
Scenario: Multi-Agent Supply-Chain Allocation & CapEx Governed Release
Decision owner: Platform Engineering Lead
Input: `.local/ideas/001-frontier-agent-governance-graph/repo-assets/sample-data/research-contract-cases.json`
Input SHA-256: `8475cea6256452b4c14c707992f19418a91d1c6264d853a3b34741b2da728f29`
Case boundary: expected 16; observed 16
Negative cases: 12
Observed mismatches: 0
Validation: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/Test-IdeaEvidence.ps1 -IdeaFolder .local/ideas/001-frontier-agent-governance-graph`

## Decision

**PASS**

## Failure contract

Agent tool boundary breach, unvetted SAP ERP mutation, or unmonitored recursive loop

Escalation rule: HOLD FOR HUMAN DUAL-SIGNATURE

## Case matrix

| Test | Failure class | Synthetic input | Expected | Observed | Negative |
|---|---|---|---|---|---|
| SEC-01 | Unauthorized Access | sp-agent-sla-reader -> Read Vendor SLA PDF | PERMIT | PERMIT | no |
| SEC-02 | Boundary Breach | sp-agent-sla-reader -> Query Fabric TMDL Model | DENY | DENY | yes |
| SEC-03 | Privilege Escalation | sp-agent-sla-reader -> Write SAP ERP Batch | DENY | DENY | yes |
| SEC-04 | Unauthorized Access | sp-agent-sla-reader -> Purview Admin Api | DENY | DENY | yes |
| SEC-05 | Scope Elevation | sp-agent-sla-reader -> Cosmos DB Master Key Access | DENY | DENY | yes |
| SEC-06 | Authorized Access | sp-agent-fabric-eval -> Direct Lake Query Realized_Capacity | PERMIT | PERMIT | no |
| SEC-07 | Boundary Breach | sp-agent-fabric-eval -> Raw SQL DirectQuery Injection | DENY | DENY | yes |
| SEC-08 | Boundary Breach | sp-agent-fabric-eval -> Read Vendor Legal Contracts | DENY | DENY | yes |
| SEC-09 | Privilege Escalation | sp-agent-fabric-eval -> Mutate SAP ERP Batch | DENY | DENY | yes |
| SEC-10 | Authorized Access | sp-agent-erp-stager -> Write Decision Proposal to Cosmos DB | PERMIT | PERMIT | no |
| SEC-11 | Gate Bypass | sp-agent-erp-stager -> Mutate SAP Without Human Dual-Signature | DENY | DENY | yes |
| SEC-12 | Boundary Breach | sp-agent-erp-stager -> Read SharePoint Document Libraries | DENY | DENY | yes |
| SEC-13 | Recursive Loop | multi-agent-session -> Exceed 12-Turn Circuit Breaker | DENY | DENY | yes |
| SEC-14 | Identity Spoofing | unregistered-agent -> Token Issuance Without Entra SPN | DENY | DENY | yes |
| SEC-15 | Injection Attack | inbound-prompt -> Defender Runtime Injection Trigger | DENY | DENY | yes |
| SEC-16 | Authorized Access | sp-agent-erp-stager -> Emit Teams Copilot Approval Card | PERMIT | PERMIT | no |

## Falsifier

Can any agent execute an unapproved state mutation against the ERP or bypass Entra ID OAuth scopes?

## Boundary

These results validate only the checked-in deterministic fixture. They do not establish live Azure or Microsoft 365 behaviour, production reliability, security certification, Microsoft-prescribed thresholds or independent reviewer approval.
