
-- ============================================================
-- Project: TechStore Algeria - ERP Business Analytics
-- Report: Financial Performance Analytics
-- Author: Walid Bouremel
-- Database: MariaDB / ERPNext v16
-- Source: General Ledger (tabGL Entry)
-- Dataset: Simulated business transactions
-- ============================================================

-- Purpose:
-- Compare sales revenue, cost of goods sold and gross profit.
-- Transform financial metrics into a chart-ready dataset.

WITH financial_data AS (

    SELECT

        -- Total sales revenue
        COALESCE(SUM(
            CASE
                WHEN account = 'Sales - TSA'
                THEN credit - debit
                ELSE 0
            END
        ), 0) AS revenue,

        -- Total cost of goods sold
        COALESCE(SUM(
            CASE
                WHEN account = 'Cost of Goods Sold - TSA'
                THEN debit - credit
                ELSE 0
            END
        ), 0) AS cogs

    FROM `tabGL Entry`

    WHERE company = 'TechStore Algeria'
        AND is_cancelled = 0
        AND posting_date BETWEEN '2026-01-01'
                             AND '2026-12-31'

)

-- Revenue
SELECT
    'Revenue' AS metric,
    ROUND(revenue, 2) AS amount
FROM financial_data

UNION ALL

-- Cost of goods sold
SELECT
    'Cost of Goods Sold' AS metric,
    ROUND(cogs, 2) AS amount
FROM financial_data

UNION ALL

-- Gross profit
SELECT
    'Gross Profit' AS metric,
    ROUND(revenue - cogs, 2) AS amount
FROM financial_data;

-- ============================================================
-- Limitations:
-- Uses a fixed fiscal year and company-specific account names.
-- Gross profit excludes operating expenses, taxes and other
-- non-operating income or expenses.
-- ============================================================
