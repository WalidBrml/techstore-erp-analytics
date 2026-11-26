
-- ============================================================
-- Project: TechStore Algeria - ERP Business Analytics
-- Report: Bank Balance Analytics
-- Author: Walid Bouremel
-- Database: MariaDB / ERPNext v16
-- Source: General Ledger (tabGL Entry)
-- Dataset: Simulated business transactions
-- ============================================================

-- Purpose:
-- Track incoming and outgoing bank transactions.
-- Calculate the running bank balance using window functions.
-- Classify transactions by their financial purpose.

SELECT

    -- Sequential transaction number and category
    CONCAT(
        ROW_NUMBER() OVER (
            ORDER BY posting_date, creation, name
        ),
        ' - ',
        CASE
            WHEN voucher_type = 'Journal Entry'
                THEN 'Journal Entry'

            WHEN voucher_type = 'Payment Entry'
                AND debit > credit
                THEN 'Cash Received'

            WHEN voucher_type = 'Payment Entry'
                AND credit > debit
                THEN 'Cash Paid'

            ELSE voucher_type
        END
    ) AS transaction_label,

    -- Transaction posting date
    posting_date,

    -- Incoming cash
    ROUND(debit, 2) AS cash_inflow,

    -- Outgoing cash
    ROUND(credit, 2) AS cash_outflow,

    -- Cumulative bank balance
    ROUND(
        SUM(debit - credit) OVER (
            ORDER BY posting_date, creation, name
            ROWS BETWEEN UNBOUNDED PRECEDING
                AND CURRENT ROW
        ),
        2
    ) AS bank_balance

FROM `tabGL Entry`

WHERE company = 'TechStore Algeria'
    AND account = 'BNA Bank - TSA'
    AND is_cancelled = 0
    AND posting_date <= '2026-12-31'

ORDER BY
    posting_date,
    creation,
    name;

-- ============================================================
-- Limitations:
-- Uses a fixed reporting cutoff and a specific bank account.
-- Transactions are ordered by posting date, record creation
-- timestamp and unique ledger entry identifier.
-- This order does not necessarily reflect actual bank
-- transaction timestamps.
-- All transactions in this simulated dataset occurred
-- on the same day. Results represent transaction-level
-- balance evolution rather than a historical time-series trend.
-- ============================================================
