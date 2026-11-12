6. Workflow Automation
AUTO-FLOW — Design the Claims Follow-Up Automation
Business requirement: Claims Operations wants a repeatable scheduled workflow that extracts claim updates, validates them, loads SQLite, generates the follow-up report, and logs run status.

Enter exactly seven ordered steps covering scheduler, API, HTTP/schema validation, raw JSON storage, SQLite loading, SQL report generation, and logging/monitoring.


[ ]
# ✍️ SQL DEVELOPER WORKSPACE — AUTO-FLOW
# TODO: Enter exactly seven ordered process steps. Keep this TODO guidance visible.
automation_steps = [
    "Trigger workflow via cron scheduler on configured frequency",
    "Call claims internal API endpoint to extract latest updates",
    "Perform HTTP status check and payload schema validation",
    "Persist raw JSON payload into raw storage directory",
    "Load validated records into SQLite database tables",
    "Execute SQL query to generate claims follow-up report",
    "Log pipeline run status and execution metrics in audit table"
]
auto_keywords = [['scheduler'], ['api'], ['http', 'schema'], ['json'], ['sqlite'], ['sql', 'report'], ['log']]
validate_sequence('AUTO-FLOW', automation_steps, auto_keywords, 'Scheduled Claims Follow-Up Workflow')

Expected Output — AUTO-FLOW
Exactly seven ordered steps and a visible left-to-right diagram. The validator checks the presence and order of scheduler, API call, HTTP/schema validation, raw JSON, SQLite load, SQL report, and logging/monitoring.

AUTO-REPORT — Write the Scheduled Claims Follow-Up Report
Business requirement: At each scheduled run, Claims Operations needs open claim-related exceptions grouped by insurer and severity, with counts, total exception value, and the oldest claim age.

Tables to use: billing_claim_exceptions, insurers, claims.


[ ]
# ✍️ SQL DEVELOPER WORKSPACE — AUTO-REPORT
# TODO: Write the scheduled operational SQL report. Keep this TODO guidance visible.
auto_report_query = """
SELECT
    ins.insurer_name,
    bce.severity,
    COUNT(bce.exception_id) AS open_exception_count,
    ROUND(SUM(bce.exception_amount), 2) AS total_exception_value,
    MAX(CAST(ROUND(julianday('2026-07-05') - julianday(c.submitted_date)) AS INTEGER)) AS oldest_claim_age_days
FROM billing_claim_exceptions bce
JOIN insurers ins ON bce.insurer_id = ins.insurer_id
JOIN claims c ON bce.claim_id = c.claim_id
WHERE bce.status = 'OPEN'
GROUP BY
    ins.insurer_name,
    bce.severity
ORDER BY
    CASE bce.severity
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        WHEN 'LOW' THEN 4
        ELSE 5
    END ASC,
    open_exception_count DESC,
    total_exception_value DESC,
    oldest_claim_age_days DESC,
    ins.insurer_name ASC;
"""
validate_sql('AUTO-REPORT', auto_report_query)

Expected Output — AUTO-REPORT
Required columns: insurer_name | severity | open_exception_count | total_exception_value | oldest_claim_age_days
Expected row count: 22

Stable first row / key result

Column	Stable first-row value
insurer_name	EverSure Health
severity	CRITICAL
open_exception_count	3
total_exception_value	47840.0
oldest_claim_age_days	79
Hint: Use grouped aggregation, LEFT JOINs, a severity-aware ORDER BY, and a date-age calculation.

AUTO-CRON — Write Cron Expressions
Enter the four five-field cron expressions. These expressions are cron-ready, but a Google Colab runtime cannot remain active as a permanent scheduler after the runtime stops.


[ ]
# ✍️ SQL DEVELOPER WORKSPACE — AUTO-CRON
# TODO: Fill all four cron expressions. Keep this TODO guidance visible.
cron_expressions = {
    'Three times per day': '0 8,12,16 * * *',
    'Weekday 5 PM': '0 17 * * 1-5',
    'Daily midnight': '0 0 * * *',
    'Sunday 2 AM': '0 2 * * 0',
}
validate_cron(cron_expressions)

Expected Output — AUTO-CRON
Scenario	Expected expression
Daily at 8 AM, 12 PM, and 4 PM	0 8,12,16 * * *
Every weekday at 5 PM	0 17 * * 1-5
Every day at midnight	0 0 * * *
Every Sunday at 2 AM	0 2 * * 0
7. Engineering Practices

6 cells hidden
8. Progress Check

[ ]
completion_dashboard_df, completion_status_counts = completion_dashboard()
display(completion_dashboard_df); display(completion_status_counts)
print(f"Passed activities: {(completion_dashboard_df['Status']=='Passed').sum()} / {len(completion_dashboard_df)}")

