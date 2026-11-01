# Revolut Home Task

This repository contains Python preprocessing steps, SQLite DDL and analysis queries, and CSV outputs used in the Revolut Home Task

## Setup

Use Python 3.11 or later. From the repository root, create and activate a virtual environment, then install the pinned dependencies:

```powershell
py -3.11 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

On macOS or Linux, use the corresponding activation command:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

The source workbook is expected at `data/Data Set - Home Task.xlsx`, with the source records on the `Data` sheet.

## Run the pipeline

Run these scripts from the repository root, in order:

```bash
python data-cleanup-preprocessing.py
python refresh-sql-output.py
```

`data-cleanup-preprocessing.py` creates or replaces:

- `data/processed_case_study_data.csv`
- The SQLite table `case_study_data` in `data/revolut_home_task.db`

`refresh-sql-output.py` executes each SQL file in `sql/ddl/`, then each query in `sql/queries/`, and writes a CSV named after each query to `outputs/`. It creates the output directory if needed. Re-run preprocessing before refreshing SQL outputs whenever the source workbook or preprocessing logic changes.

## Data preprocessing

The preprocessing script reads the workbook's `Data` sheet and applies the following transformations:

1. Renames the source `Unnamed: 0` column to `row_id`.
2. Normalizes `account_level_4` from `Fair Usage Fee` to `Fair Usage Fees`.
3. Assigns a `period` based on the number of days since the earliest `pnl_date`: days 0–30 are period 1, days 31–60 are period 2, and later days are period 3.
4. Corrects plan labels that conflict with user type: personal users are assigned `STANDARD`; business, business employee, and business user records labeled `STANDARD` are assigned `COMPANY_BASIC`. Personal users with no plan are also assigned `STANDARD`.
5. Replaces `user_id` values of `0` with `inf-<row_id>` to give those rows distinct inferred IDs.
6. Uses `sql/preprocessing/rev-expense-classification.sql` to classify each distinct account path, grouped by the exact combination of `account_level_1` through `account_level_4`. For each path, the SQL counts rows with `amount_gbp >= 0` as `count_of_revenues` (so zero-valued rows count here) and rows with `amount_gbp < 0` as `count_of_costs`; it compares row counts, not summed amounts.
   - It first checks all four account-level labels for the substring `FEE`, case-insensitively. A match classifies the path as `revenue`.
   - If no label contains `FEE`, it checks all four labels for `CHARGE`; a match classifies the path as `expense`. Thus, if a path contains both terms, `FEE` takes precedence.
   - If neither term appears, more non-negative rows than negative rows means `revenue`; more negative rows means `expense`; equal counts mean the path remains unclassified (`NULL`).
   - Null account labels are treated as empty strings for the keyword checks, so they do not themselves match either keyword.
7. Left-joins the resulting classification to every source row using the exact values of account levels 1–4. This adds `revenue_expense` while retaining rows even if their path has a `NULL` classification.

## DDL

`sql/ddl/user-aggregation.sql` drops and recreates the SQLite table `user_data` from `case_study_data`. It builds a per-user dataset containing the latest available NAP status, onboarding date, state, plan/type and geography, along with aggregate profitability and selected revenue/expense categories. The plan/type fields also include the previous observed plan/type where available.

The refresh script runs this DDL before the analysis queries, so `user_data` is rebuilt on every refresh.

## Queries and outputs

Each SQL file in `sql/queries/` produces a same-named CSV in `outputs/`:

| SQL query | Output | Summary |
|---|---|---|
| `card-payments-margins.sql` | `card-payments-margins.csv` | Identifies users with top-up, ATM, or bank-payment activity and returns related revenue/expense measures. |
| `export-rev-expense-classification.sql` | `export-rev-expense-classification.csv` | Lists account paths and counts of positive and negative amount rows by revenue/expense classification. |
| `user-groups-lvl3-accounts.sql` | `user-groups-lvl3-accounts.csv` | Counts distinct interacting users by user group and account levels 1–3. |
| `user-groups.sql` | `user-groups.csv` | Counts users in each mapped group: retail, business, youth, and company. |
| `users-by-type-plan.sql` | `users-by-type-plan.csv` | Counts users by mapped user group and plan. |
| `vending-machine-rewards.sql` | `vending-machine-rewards.csv` | Returns users with vending-machine rewards, including reward percentile rank and decile within NAP status. |

`outputs/user-profitability.csv` may exist as a previously produced file, but it is not regenerated by `refresh-sql-output.py`: there is no corresponding query under `sql/queries/`.
