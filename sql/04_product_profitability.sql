
-- ============================================================
-- Project: TechStore Algeria - ERP Business Analytics
-- Report: Product Profitability Analytics
-- Author: Walid Bouremel
-- Database: MariaDB / ERPNext v16
-- Dataset: Simulated business transactions
-- ============================================================

-- Purpose:
-- Calculate revenue, cost of goods sold, gross profit
-- and gross margin for each product.
-- Combine sales invoice data with stock ledger movements.

SELECT

    sii.item_name AS product,

    -- Total product revenue
    ROUND(
        SUM(sii.base_net_amount),
        2
    ) AS revenue,

    -- Cost of goods sold
    ROUND(
        SUM(COALESCE(cost.cogs, 0)),
        2
    ) AS cogs,

    -- Gross profit
    ROUND(
        SUM(sii.base_net_amount)
        - SUM(COALESCE(cost.cogs, 0)),
        2
    ) AS gross_profit,

    -- Gross profit margin
    ROUND(
        (
            SUM(sii.base_net_amount)
            - SUM(COALESCE(cost.cogs, 0))
        ) * 100.0
        / NULLIF(SUM(sii.base_net_amount), 0),
        2
    ) AS gross_margin

FROM `tabSales Invoice Item` AS sii

INNER JOIN `tabSales Invoice` AS si
    ON sii.parent = si.name

LEFT JOIN (

    -- Calculate inventory cost for each delivery note item
    SELECT

        voucher_no,

        voucher_detail_no,

        SUM(-stock_value_difference) AS cogs

    FROM `tabStock Ledger Entry`

    WHERE company = 'TechStore Algeria'
        AND voucher_type = 'Delivery Note'
        AND is_cancelled = 0

    GROUP BY
        voucher_no,
        voucher_detail_no

) AS cost

    ON cost.voucher_no = sii.delivery_note
    AND cost.voucher_detail_no = sii.dn_detail

WHERE si.company = 'TechStore Algeria'
    AND si.docstatus = 1
    AND si.posting_date BETWEEN '2026-01-01'
                            AND '2026-12-31'

GROUP BY
    sii.item_code,
    sii.item_name

ORDER BY
    gross_profit DESC;

-- ============================================================
-- Limitations:
-- Designed for the simulated delivery-note-based sales workflow.
-- Assumes delivery note items are fully invoiced.
-- Partial invoicing, returns and direct stock-updating invoices
-- require additional cost allocation logic.
-- Missing stock ledger matches are treated as zero cost,
-- which may overstate profitability in other datasets.
-- Uses a fixed fiscal year and company name.
-- ============================================================
