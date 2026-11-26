
-- ============================================================
-- Project: TechStore Algeria - ERP Business Analytics
-- Report: Inventory Analytics
-- Author: Walid Bouremel
-- Database: MariaDB / ERPNext v16
-- Dataset: Simulated business transactions
-- ============================================================

-- Purpose:
-- Analyze inventory movements for each product.
-- Calculate purchased quantities, sold quantities
-- and remaining stock using Stock Ledger entries.

SELECT

    i.item_name AS product,

    -- Total purchased quantity
    ROUND(
        SUM(
            CASE
                WHEN sle.voucher_type IN (
                    'Purchase Receipt',
                    'Purchase Invoice'
                )
                THEN sle.actual_qty
                ELSE 0
            END
        ),
        2
    ) AS purchased_qty,

    -- Total sold quantity
    ROUND(
        SUM(
            CASE
                WHEN sle.voucher_type IN (
                    'Delivery Note',
                    'Sales Invoice'
                )
                THEN -sle.actual_qty
                ELSE 0
            END
        ),
        2
    ) AS sold_qty,

    -- Remaining inventory quantity
    ROUND(
        SUM(sle.actual_qty),
        2
    ) AS remaining_qty

FROM `tabStock Ledger Entry` AS sle

INNER JOIN `tabItem` AS i
    ON sle.item_code = i.name

WHERE sle.company = 'TechStore Algeria'
    AND sle.is_cancelled = 0
    AND sle.docstatus = 1
    AND sle.posting_date <= '2026-12-31'

GROUP BY
    sle.item_code,
    i.item_name

ORDER BY
    sold_qty DESC;

-- ============================================================
-- Limitations:
-- Uses a fixed reporting cutoff and company name.
-- Quantities are aggregated across company warehouses.
-- Purchase and sales quantities represent net stock movements.
-- Stock adjustments, manufacturing and warehouse transfers
-- may require separate analysis in more complex datasets.
-- ============================================================
