# Apollo Hospitals Billing & Insurance Claims Control Layer
An automated SQL control layer that identifies unbilled clinical services, tracks rejected insurance claims, and flags unpaid invoices to prevent hospital revenue leakage. 
## Key Audit Findings
* **Unbilled Revenue Leak:** Identified 118 unbilled service lines (8.82% of 1,338 total lines) worth ₹6,00,500.
* **Insurer Rejection Variance:** PrimeCare recorded the highest observed rejection rate at 39.13%.
* **Open Audit Exceptions:** Flagged 652 open exceptions across unbilled services, claim-to-invoice mismatches, and unpaid balances.
* **Automated Validation:** 26 of 26 integrity, constraint, and reconciliation checks passed.
## Technical Implementation & Skills
* **SQL & Data Modeling:** Multi-table `JOIN`s, Common Table Expressions (CTEs), Window Functions (`DENSE_RANK`, running totals), and `CHECK` constraints.
* **ACID Transactions:** Implemented `COMMIT` and `ROLLBACK` logic to ensure atomic updates across claims and invoices.
* **Python & API Integration:** REST API ingestion and CRUD lifecycle testing via `requests`, orchestrated with SQLite.
## Documentation & Execution
* **Schema Design:** ![ER Diagram](docs/er_diagram.png)
* **Validation Output:** ![Validation Dashboard](docs/dashboard.png)
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/omprakash-ds/apollo-billing-claims-sql/blob/main/notebooks/Apollo_Billing_Claims.ipynb)
