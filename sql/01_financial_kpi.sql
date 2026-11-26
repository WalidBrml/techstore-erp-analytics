
-- ============================================================
-- Project: TechStore Algeria - ERP Business Analytics
-- Report: Financial KPI Analytics
-- Author: Walid Bouremel
-- Database: MariaDB / ERPNext v16
-- Source: General Ledger (tabGL Entry)
-- Dataset: Simulated business transactions
-- ============================================================

-- Purpose:
-- Calculate eight financial KPIs using conditional aggregation.
-- Exclude cancelled accounting entries.
-- Restrict analysis to TechStore Algeria.

SELECT
    ROUND(revenue, 2) AS total_revenue,

    ROUND(cogs, 2) AS cost_of_goods_sold,

    ROUND(revenue - cogs, 2) AS gross_profit,

    ROUND(
        COALESCE(
            (revenue - cogs) * 100.0 / NULLIF(revenue, 0),
            0
        ),
        2
    ) AS gross_margin,

    ROUND(bank_balance, 2) AS bank_balance,

    ROUND(inventory_value, 2) AS inventory_value,

    ROUND(receivables, 2) AS accounts_receivable,

    ROUND(payables, 2) AS accounts_payable

FROM (

    SELECT

        -- Sales revenue
        COALESCE(SUM(
            CASE
                WHEN account = 'Sales - TSA'
                THEN credit - debit
                ELSE 0
            END
        ), 0) AS revenue,

        -- Cost of goods sold
        COALESCE(SUM(
            CASE
                WHEN account = 'Cost of Goods Sold - TSA'
                THEN debit - credit
                ELSE 0
            END
        ), 0) AS cogs,

        -- Bank balance
        COALESCE(SUM(
            CASE
                WHEN account = 'BNA Bank - TSA'
                THEN debit - credit
                ELSE 0
            END
        ), 0) AS bank_balance,

        -- Inventory valuation
        COALESCE(SUM(
            CASE
                WHEN account = 'Stock In Hand - TSA'
                THEN debit - credit
                ELSE 0
            END
        ), 0) AS inventory_value,

        -- Customer receivables
        COALESCE(SUM(
            CASE
                WHEN account = 'Debtors - TSA'
                THEN debit - credit
                ELSE 0
            END
        ), 0) AS receivables,

        -- Supplier payables
        COALESCE(SUM(
            CASE
                WHEN account = 'Creditors - TSA'
                THEN credit - debit
                ELSE 0
            END
        ), 0) AS payables

    FROM `tabGL Entry`

    WHERE company = 'TechStore Algeria'
        AND is_cancelled = 0
        AND posting_date <= '2026-12-31'

) AS financial_data;

-- ============================================================
-- Limitations:
-- Fixed reporting cutoff and company-specific account names.
-- Revenue and COGS are cumulative through the cutoff date.
-- A multi-year dataset would require separate period filtering
-- for income statement metrics and balance sheet balances.
-- ============================================================
