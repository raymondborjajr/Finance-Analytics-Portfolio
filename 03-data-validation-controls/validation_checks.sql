-- Data validation and reconciliation checks (SQLite-compatible; adapt syntax for SQL Server/Postgres)
-- Table: billing(invoice_id, customer_id, invoice_date, tier, amount, status, gl_posted_amount, gl_post_date)
-- All data is synthetic.

-- Check 1: Duplicate invoice ID
SELECT rowid AS row_id, invoice_id FROM billing b WHERE rowid > (SELECT MIN(rowid) FROM billing WHERE invoice_id=b.invoice_id);

-- Check 2: Billing vs GL amount mismatch
SELECT rowid AS row_id, invoice_id FROM billing WHERE gl_posted_amount IS NOT NULL AND ABS(amount-gl_posted_amount) > 0.01;

-- Check 3: Missing customer ID
SELECT rowid AS row_id, invoice_id FROM billing WHERE customer_id IS NULL OR TRIM(customer_id)='';

-- Check 4: Invalid tier
SELECT rowid AS row_id, invoice_id FROM billing WHERE tier NOT IN ('Starter','Growth','Enterprise');

-- Check 5: Negative amount (not a credit)
SELECT rowid AS row_id, invoice_id FROM billing WHERE amount < 0;

-- Check 6: Not posted to GL
SELECT rowid AS row_id, invoice_id FROM billing WHERE gl_posted_amount IS NULL;

-- Check 7: Invoice date outside FY2026
SELECT rowid AS row_id, invoice_id FROM billing WHERE invoice_date < '2026-01-01' OR invoice_date > '2026-12-31';

-- Summary: exceptions by check
-- Run each check above and UNION ALL the results with a literal check name, then GROUP BY check.
