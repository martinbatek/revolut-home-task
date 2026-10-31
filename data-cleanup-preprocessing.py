#!/usr/bin/env python3

import sqlite3
from pathlib import Path

import numpy as np
import pandas as pd


BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "data"
EXCEL_PATH = DATA_DIR / "Data Set - Home Task.xlsx"
DB_PATH = DATA_DIR / "revolut_home_task.db"


def main() -> None:

    conn = sqlite3.connect(DB_PATH)
    try:
        # Read data into Pandas dataframe
        data = pd.read_excel(
            EXCEL_PATH,
            sheet_name="Data",
            dtype={
                "Unnamed: 0": "int64",
                "user_id": "string",
                "user_city": "string",
                "user_country": "string",
                "account_level_1": "string",
                "account_level_2": "string",
                "account_level_3": "string",
                "account_level_4": "string",
                "amount_gbp": "float64",
                "user_type": "string",
                "age_group": "string",
                "user_state": "string",
                "user_plan": "string",
                "is_nap": "string",
            },
            parse_dates=["pnl_date", "onboarded_date", "pnl_month"],
        )

        # Preprocessing
        data.rename(columns={"Unnamed: 0": "row_id"}, inplace=True)

        data.loc[(data["account_level_4"] == "Fair Usage Fee"), ["account_level_4"]] = "Fair Usage Fees"

        # Add a column identifying the 3 30 day periods
        start_date = data.pnl_date.min()
        data["period"] = np.where(
            (data.pnl_date - start_date).dt.days <= 30,
            1,
            np.where(
                (data.pnl_date - start_date).dt.days <= 60,
                2,
                3,
            ),
        )

        # Correct user plan and type tags that contradict the case study
        data.loc[
            (data.user_type == "PERSONAL")
            & (data.user_plan.isin(["COMPANY_BASIC", "COMPANY_GROW", "COMPANY_SCALE"])),
            ["user_plan"],
        ] = "STANDARD"

        data.loc[
            (data.user_type == "BUSINESS") & (data.user_plan == "STANDARD"),
            ["user_plan"],
        ] = "COMPANY_SCALE"

        data.loc[
            (data.user_type.isin(["BUSINESS_EMPLOYEE", "BUSINESS_USER"]))
            & (data.user_plan == "STANDARD"),
            ["user_plan"],
        ] = "COMPANY_BASIC"

        data.loc[
            (data.user_type == "PERSONAL") & (data.user_plan.isnull()),
            ["user_plan"],
        ] = "STANDARD"

        # Infer distinct user IDs for lines where user_id = '0'
        data.loc[(data.user_id == "0"), ["user_id"]] = "inf-" + data.loc[(data.user_id == "0")].row_id.astype(str)

        rows_overwritten = data.to_sql(
            "case_study_data",
            conn,
            if_exists="replace",
        )
        print(f"Table case_study_data successfully overwritten with {rows_overwritten} rows.")
    finally:
        conn.close()

        # Write data to csv
        data.to_csv('data/processed_case_study_data.csv',index=False)


if __name__ == "__main__":
    main()
