4. SQL Developer Questions

[ ]

4A. SQL Foundations and Multiple Tables
Q1 — Largest Outstanding Patient Invoices
Business requirement: Revenue Cycle Operations needs the eight largest outstanding invoices still requiring follow-up.

Tables to use: invoices, visits, patients, payments

How to approach: Join invoices to patients through visits, aggregate posted payments, calculate outstanding balance, filter positive balances, then sort descending and limit to eight.


[ ]
# ✍️ SQL DEVELOPER WORKSPACE — Q1
# TODO: Write the SQL for Q1 here. Keep this TODO guidance visible.
q1_query = """
SELECT
    i.invoice_id,
    p.patient_id,
    p.full_name,
    i.gross_amount,
    ROUND(i.gross_amount - COALESCE(SUM(pay.amount), 0), 2) AS outstanding_balance
FROM invoices i
JOIN visits v ON i.visit_id = v.visit_id
JOIN patients p ON v.patient_id = p.patient_id
LEFT JOIN payments pay
    ON i.invoice_id = pay.invoice_id
   AND pay.payment_status = 'POSTED'
GROUP BY
    i.invoice_id,
    p.patient_id,
    p.full_name,
    i.gross_amount
HAVING outstanding_balance > 0
ORDER BY outstanding_balance DESC, i.invoice_id ASC
LIMIT 8;
"""
validate_sql('Q1', q1_query)

Expected Output — Q1
Required columns: invoice_id | patient_id | full_name | gross_amount | outstanding_balance
Expected row count: 8

Stable first row / key result

Column	Stable first-row value
invoice_id	INV00340
patient_id	PAT0069
full_name	Rahul Gupta
gross_amount	44900.0
outstanding_balance	44900.0
Hint: JOIN, WHERE, GROUP BY, HAVING, ORDER BY, LIMIT

Q2 — Insurer Claim Volume and Rejection Rate
Business requirement: The Claims Manager needs insurer-level claim volume, claimed value, and rejection rate for insurers with material activity.

Tables to use: insurers, claims

How to approach: Group claims by insurer; calculate count, claimed value, and rejected percentage; use HAVING for minimum volume and value.


[ ]
# ✍️ SQL DEVELOPER WORKSPACE — Q2
# TODO: Write the SQL for Q2 here. Keep this TODO guidance visible.
q2_query = """
SELECT
    i.insurer_id,
    i.insurer_name,
    COUNT(c.claim_id) AS claim_count,
    ROUND(SUM(c.claimed_amount), 2) AS claimed_value,
    ROUND(100.0 * SUM(CASE WHEN c.claim_status = 'REJECTED' THEN 1 ELSE 0 END) / COUNT(c.claim_id), 2) AS rejection_rate_pct
FROM insurers i
JOIN claims c ON i.insurer_id = c.insurer_id
GROUP BY
    i.insurer_id,
    i.insurer_name
HAVING claim_count > 0
ORDER BY rejection_rate_pct DESC, claimed_value DESC;
"""
validate_sql('Q2', q2_query)


Expected Output — Q2
Required columns: insurer_id | insurer_name | claim_count | claimed_value | rejection_rate_pct
Expected row count: 8

Stable first row / key result

Column	Stable first-row value
insurer_id	INS007
insurer_name	PrimeCare Insurance
claim_count	23
claimed_value	269745.0
rejection_rate_pct	39.13
Hint: GROUP BY, SUM, COUNT, CASE, HAVING

Q3 — Invoice-to-Claim Reconciliation
Business requirement: Finance Controls needs insured invoices where approved claim value does not reconcile to the expected insurer share.

Tables to use: invoices, insurance_policies, insurers, claims

How to approach: Join invoice policy and insurer data, LEFT JOIN claims, aggregate approved claim value, and classify each invoice with CASE.


[ ]
# ✍️ SQL DEVELOPER WORKSPACE — Q3
# TODO: Write the SQL for Q3 here. Keep this TODO guidance visible.
q3_query = """
SELECT
    i.invoice_id,
    ins.insurer_name,
    i.insurer_share AS expected_insurer_share,
    ROUND(COALESCE(SUM(c.approved_amount), 0.0), 2) AS approved_claim_value,
    CASE
        WHEN ABS(i.insurer_share - COALESCE(SUM(c.approved_amount), 0.0)) <= 0.01 THEN 'RECONCILED'
        ELSE 'MISMATCHED'
    END AS reconciliation_status
FROM invoices i
JOIN insurance_policies pol ON i.policy_id = pol.policy_id
JOIN insurers ins ON pol.insurer_id = ins.insurer_id
LEFT JOIN claims c ON i.invoice_id = c.invoice_id
WHERE i.insurer_share > 0
GROUP BY
    i.invoice_id,
    ins.insurer_name,
    i.insurer_share
HAVING reconciliation_status = 'MISMATCHED'
ORDER BY i.invoice_id ASC
LIMIT 20;
"""
validate_sql('Q3', q3_query)

Expected Output — Q3
Required columns: invoice_id | insurer_name | expected_insurer_share | approved_claim_value | reconciliation_status
Expected row count: 20

Stable first row / key result

Column	Stable first-row value
invoice_id	INV00002
insurer_name	Wellness Shield TPA
expected_insurer_share	28092.5
approved_claim_value	0.0
reconciliation_status	MISMATCHED
Hint: LEFT JOIN, COALESCE, CASE, aggregation

Q4 — Delivered Services Not Billed
Business requirement: Billing Operations needs delivered service lines that have no matching invoice.

Tables to use: visit_services, visits, patients, services, invoices

How to approach: LEFT JOIN the invoice reference and keep delivered lines where the invoice side is NULL. Sort high-value services first.


[ ]
# ✍️ SQL DEVELOPER WORKSPACE — Q4
# TODO: Write the SQL for Q4 here. Keep this TODO guidance visible.
q4_query = """
SELECT
    vs.visit_id,
    vs.service_line_no,
    p.patient_id,
    p.full_name,
    s.service_name,
    vs.charge_amount
FROM visit_services vs
JOIN visits v ON vs.visit_id = v.visit_id
JOIN patients p ON v.patient_id = p.patient_id
JOIN services s ON vs.service_id = s.service_id
LEFT JOIN invoices i ON vs.invoice_id = i.invoice_id
WHERE vs.service_status = 'DELIVERED'
  AND i.invoice_id IS NULL
ORDER BY vs.charge_amount DESC, vs.visit_id ASC, vs.service_line_no ASC
LIMIT 15;
"""
validate_sql('Q4', q4_query)


Expected Output — Q4
Required columns: visit_id | service_line_no | patient_id | full_name | service_name | charge_amount
Expected row count: 15

Stable first row / key result

Column	Stable first-row value
visit_id	VIS00010
service_line_no	2
patient_id	PAT0017
full_name	Diya Mehta
service_name	Chemotherapy Session
charge_amount	28500.0
Hint: LEFT JOIN, IS NULL, anti-join pattern

4B. SQL Functions, Set Operations, Subqueries, and CTEs
Q5 — Rejected-Claim Patients with Outstanding Invoices
Business requirement: The claims follow-up team needs patients who appear in both the rejected-claim population and the outstanding-invoice population.

Tables to use: patients, visits, invoices, claims, payments

How to approach: Build the two patient sets and combine them with INTERSECT; return patient identity once.


[ ]
# ✍️ SQL DEVELOPER WORKSPACE — Q5
# TODO: Write the SQL for Q5 here. Keep this TODO guidance visible.
q5_query = """
SELECT patient_id, full_name
FROM (
    -- Population 1: Patients with rejected claims
    SELECT DISTINCT p.patient_id, p.full_name
    FROM patients p
    JOIN visits v ON p.patient_id = v.patient_id
    JOIN invoices i ON v.visit_id = i.visit_id
    JOIN claims c ON i.invoice_id = c.invoice_id
    WHERE c.claim_status = 'REJECTED'

    INTERSECT

    -- Population 2: Patients with outstanding invoices
    SELECT DISTINCT p.patient_id, p.full_name
    FROM patients p
    JOIN visits v ON p.patient_id = v.patient_id
    JOIN invoices i ON v.visit_id = i.visit_id
    LEFT JOIN payments pay
        ON i.invoice_id = pay.invoice_id
       AND pay.payment_status = 'POSTED'
    GROUP BY p.patient_id, p.full_name, i.invoice_id, i.gross_amount
    HAVING (i.gross_amount - COALESCE(SUM(pay.amount), 0.0)) > 0.01
)
ORDER BY patient_id ASC;
"""
validate_sql('Q5', q5_query)

Expected Output — Q5
Required columns: patient_id | full_name
Expected row count: 36

Stable first row / key result

Column	Stable first-row value
patient_id	PAT0002
full_name	Meera Das
Hint: INTERSECT, subqueries, aggregation

Q6 — Insurer Risk Summary with Business-Readable Fields
Business requirement: The Revenue Cycle Manager needs normalized insurer labels, recency, rejection rate, and a risk band.

Tables to use: insurers, claims

How to approach: Build claim statistics, apply string/date/NULL functions, cast the percentage, and classify risk with CASE.


[ ]
# ✍️ SQL DEVELOPER WORKSPACE — Q6
# TODO: Write the SQL for Q6 here. Keep this TODO guidance visible.
q6_query = """
SELECT
    i.insurer_id,
    UPPER(i.insurer_name) AS insurer_name_upper,
    SUBSTR(i.insurer_name, 1, 12) AS insurer_short_name,
    COUNT(c.claim_id) AS claim_count,
    ROUND(100.0 * SUM(CASE WHEN c.claim_status = 'REJECTED' THEN 1 ELSE 0 END) / COUNT(c.claim_id), 2) AS rejection_rate_pct,
    CAST(ROUND(julianday('2026-07-05') - julianday(MAX(c.last_status_date))) AS INTEGER) AS days_since_latest_update,
    CASE
        WHEN (100.0 * SUM(CASE WHEN c.claim_status = 'REJECTED' THEN 1 ELSE 0 END) / COUNT(c.claim_id)) >= 25.0 THEN 'HIGH'
        WHEN (100.0 * SUM(CASE WHEN c.claim_status = 'REJECTED' THEN 1 ELSE 0 END) / COUNT(c.claim_id)) >= 15.0 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_band
FROM insurers i
JOIN claims c ON i.insurer_id = c.insurer_id
GROUP BY
    i.insurer_id,
    i.insurer_name
ORDER BY rejection_rate_pct DESC, claim_count DESC;
"""
validate_sql('Q6', q6_query)

Expected Output — Q6
Required columns: insurer_id | insurer_name_upper | insurer_short_name | claim_count | rejection_rate_pct | days_since_latest_update | risk_band
Expected row count: 8

Stable first row / key result

Column	Stable first-row value
insurer_id	INS007
insurer_name_upper	PRIMECARE INSURANCE
insurer_short_name	PrimeCare In
claim_count	23
rejection_rate_pct	39.13
days_since_latest_update	0
risk_band	HIGH
Hint: UPPER, SUBSTR, COALESCE, date functions, CAST, CASE

Q7 — Insurers Above Average Rejection Rate
Business requirement: The Claims Manager needs insurers whose rejection rate is higher than the portfolio average.

Tables to use: insurers, claims

How to approach: Calculate insurer rejection rates in a CTE and compare each rate with a scalar subquery returning the average.


[ ]
# ✍️ SQL DEVELOPER WORKSPACE — Q7
# TODO: Write the SQL for Q7 here. Keep this TODO guidance visible.
q7_query = """
WITH insurer_rejection_rates AS (
    SELECT
        i.insurer_id,
        i.insurer_name,
        COUNT(c.claim_id) AS claim_count,
        ROUND(100.0 * SUM(CASE WHEN c.claim_status = 'REJECTED' THEN 1 ELSE 0 END) / COUNT(c.claim_id), 2) AS rejection_rate_pct
    FROM insurers i
    JOIN claims c ON i.insurer_id = c.insurer_id
    GROUP BY
        i.insurer_id,
        i.insurer_name
)
SELECT
    insurer_id,
    insurer_name,
    claim_count,
    rejection_rate_pct
FROM insurer_rejection_rates
WHERE rejection_rate_pct > (
    SELECT AVG(rejection_rate_pct)
    FROM insurer_rejection_rates
)
ORDER BY rejection_rate_pct DESC, claim_count DESC;
"""
validate_sql('Q7', q7_query)

Expected Output — Q7
Required columns: insurer_id | insurer_name | claim_count | rejection_rate_pct
Expected row count: 5

Stable first row / key result

Column	Stable first-row value
insurer_id	INS007
insurer_name	PrimeCare Insurance
claim_count	23
rejection_rate_pct	39.13
Hint: standard CTE, scalar subquery

Q8 — Multi-Stage Billing and Claims Control
Business requirement: Finance Controls needs a compact invoice control view comparing billed service value, claim value, posted payments, and outstanding balance.

Tables to use: invoices, visit_services, payments, claims

How to approach: Use separate standard CTEs for billed services, posted payments, and claims, then combine and classify each invoice.


[ ]
# ✍️ SQL DEVELOPER WORKSPACE — Q8
# TODO: Write the SQL for Q8 here. Keep this TODO guidance visible.
q8_query = """
WITH billed_services AS (
    SELECT
        invoice_id,
        ROUND(SUM(charge_amount), 2) AS billed_service_value
    FROM visit_services
    WHERE invoice_id IS NOT NULL
    GROUP BY invoice_id
),
posted_payments AS (
    SELECT
        invoice_id,
        ROUND(SUM(amount), 2) AS posted_payment_value
    FROM payments
    WHERE payment_status = 'POSTED'
    GROUP BY invoice_id
),
claims_agg AS (
    SELECT
        invoice_id,
        ROUND(SUM(claimed_amount), 2) AS total_claimed
    FROM claims
    GROUP BY invoice_id
)
SELECT
    i.invoice_id,
    COALESCE(bs.billed_service_value, 0.0) AS billed_service_value,
    i.gross_amount AS invoice_gross,
    COALESCE(ca.total_claimed, 0.0) AS total_claimed,
    COALESCE(pp.posted_payment_value, 0.0) AS posted_payment_value,
    ROUND(i.gross_amount - COALESCE(pp.posted_payment_value, 0.0), 2) AS outstanding_balance,
    CASE
        WHEN ROUND(i.gross_amount - COALESCE(pp.posted_payment_value, 0.0), 2) <= 0.01 THEN 'FULLY_PAID'
        WHEN COALESCE(pp.posted_payment_value, 0.0) > 0 THEN 'PARTIALLY_PAID'
        ELSE 'OUTSTANDING'
    END AS control_status
FROM invoices i
LEFT JOIN billed_services bs ON i.invoice_id = bs.invoice_id
LEFT JOIN posted_payments pp ON i.invoice_id = pp.invoice_id
LEFT JOIN claims_agg ca ON i.invoice_id = ca.invoice_id
ORDER BY outstanding_balance DESC, i.invoice_id ASC
LIMIT 20;
"""
validate_sql('Q8', q8_query)


Expected Output — Q8
Required columns: invoice_id | billed_service_value | invoice_gross | total_claimed | posted_payment_value | outstanding_balance | control_status
Expected row count: 20

Stable first row / key result

Column	Stable first-row value
invoice_id	INV00340
billed_service_value	44900.0
invoice_gross	44900.0
total_claimed	0.0
posted_payment_value	0.0
outstanding_balance	44900.0
control_status	OUTSTANDING
Hint: multiple standard CTEs, COALESCE, CASE
