
-- ============================================================
-- Project: TechStore Algeria - ERP Business Analytics
-- Report: Receivables and Payables Analytics
-- Author: Walid Bouremel
-- Database: MariaDB / ERPNext v16
-- Source: General Ledger (tabGL Entry)
-- Dataset: Simulated business transactions
-- ============================================================

-- Purpose:
-- Calculate outstanding customer receivables.
-- Calculate outstanding supplier payables.
-- Compare short-term financial obligations and expected
-- customer collections using General Ledger balances.

-- Accounts Receivable

SELECT

    'Accounts Receivable' AS category,

    ROUND(
        COALESCE(
            SUM(debit - credit),
            0
        ),
        2
    ) AS amount

FROM `tabGL Entry`

WHERE company = 'TechStore Algeria'
    AND account = 'Debtors - TSA'
    AND is_cancelled = 0
    AND posting_date <= '2026-12-31'

UNION ALL

-- Accounts Payable

SELECT

    'Accounts Payable' AS category,

    ROUND(
        COALESCE(
            SUM(credit - debit),
            0
        ),
        2
    ) AS amount

FROM `tabGL Entry`

WHERE company = 'TechStore Algeria'
    AND account = 'Creditors - TSA'
    AND is_cancelled = 0
    AND posting_date <= '2026-12-31';

-- ============================================================
-- Limitations:
-- Uses a fixed reporting cutoff and specific account names.
-- Represents aggregate outstanding account balances.
-- Does not provide invoice-level aging analysis,
-- payment forecasts or customer credit risk assessment.
-- Additional receivable and payable accounts would require
-- broader account filtering in a production environment.
-- ============================================================
