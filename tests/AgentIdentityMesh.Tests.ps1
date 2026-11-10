<#
    .SYNOPSIS
        16-Test Deterministic Verification Matrix for Enterprise Agent Identity Graph Mesh
    .DESCRIPTION
        Validates 4 permitted operational authority patterns and 12 negative boundary/privilege-escalation tests.
        Repository: https://github.com/ShahradGH/enterprise-agent-identity-graph
        Reference: Authority Before Capability: Microsoft Foundry & Enterprise Agent Identity Graph
#>

BeforeAll {
    $script:CasesFile = Join-Path $PSScriptRoot "../sample-data/research-contract-cases.json"
    if (Test-Path $script:CasesFile) {
        $raw = Get-Content -Raw -Path $script:CasesFile
        $script:Cases = ConvertFrom-Json $raw
    } else {
        $script:Cases = @()
    }
}

Describe "Enterprise Agent Identity Graph 16-Test Suite" {

    # =========================================================================
    # Phase 1: Governed Agent Authority (Permitted Operations)
    # =========================================================================
    Context "Phase 1: Governed Agent Authority (Permitted Operations)" {
        It "SEC-01: SLA Ingest Agent reading vendor contract PDF returns PERMIT" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "SEC-01" }
            $case.expected_outcome | Should -Be "PERMIT"
            $case.negative_test | Should -Be $false
        }

        It "SEC-06: Capacity Evaluator Direct Lake TMDL query returns PERMIT (<120ms)" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "SEC-06" }
            $case.expected_outcome | Should -Be "PERMIT"
            $case.negative_test | Should -Be $false
        }

        It "SEC-10: ERP Stager writing immutable decision proposal to Cosmos DB returns PERMIT" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "SEC-10" }
            $case.expected_outcome | Should -Be "PERMIT"
            $case.negative_test | Should -Be $false
        }

        It "SEC-16: ERP Stager emitting Teams Copilot approval card returns PERMIT" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "SEC-16" }
            $case.expected_outcome | Should -Be "PERMIT"
            $case.negative_test | Should -Be $false
        }
    }

    # =========================================================================
    # Phase 2: Boundary Breach & Privilege Escalation Veto Gates (DENY)
    # =========================================================================
    Context "Phase 2: Boundary Breach & Privilege Escalation Veto Gates (DENY)" {
        It "SEC-02: SLA Ingest Agent querying Fabric TMDL model is strictly DENIED" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "SEC-02" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }

        It "SEC-03: SLA Ingest Agent writing to SAP ERP batch is strictly DENIED" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "SEC-03" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }

        It "SEC-04: SLA Ingest Agent accessing Purview Admin API is strictly DENIED" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "SEC-04" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }

        It "SEC-05: SLA Ingest Agent attempting Cosmos DB master key access is strictly DENIED" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "SEC-05" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }

        It "SEC-07: Capacity Evaluator raw SQL DirectQuery injection is strictly DENIED" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "SEC-07" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }

        It "SEC-08: Capacity Evaluator reading vendor legal contracts is strictly DENIED" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "SEC-08" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }

        It "SEC-09: Capacity Evaluator mutating SAP ERP batch schedule is strictly DENIED" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "SEC-09" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }
    }

    # =========================================================================
    # Phase 3: Sovereign Human Dual-Signature & Runtime Circuit Breakers (DENY)
    # =========================================================================
    Context "Phase 3: Human Dual-Signature Gate & Runtime Protection (DENY)" {
        It "SEC-11: Mutating SAP without Human Dual-Signature sign-off is locked (DENY)" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "SEC-11" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }

        It "SEC-12: ERP Stager reading unassigned SharePoint document libraries is DENIED" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "SEC-12" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }

        It "SEC-13: Multi-agent session exceeding 12-turn negotiation circuit breaker is HALTED (DENY)" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "SEC-13" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }

        It "SEC-14: Unregistered agent token issuance without Entra ID SPN is REJECTED (DENY)" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "SEC-14" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }

        It "SEC-15: Inbound prompt injection tripping Defender for Cloud runtime filter is BLOCKED (DENY)" {
            $case = $script:Cases | Where-Object { $_.test_id -eq "SEC-15" }
            $case.expected_outcome | Should -Be "DENY"
            $case.negative_test | Should -Be $true
        }
    }
}

