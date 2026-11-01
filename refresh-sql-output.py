#!/usr/bin/env python3

import csv
import sqlite3
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
DB_PATH = BASE_DIR / "data" / "revolut_home_task.db"
DDL_DIR = BASE_DIR / "sql" / "ddl"
QUERIES_DIR = BASE_DIR / "sql" / "queries"
OUTPUTS_DIR = BASE_DIR / "outputs"


def main() -> None:
    OUTPUTS_DIR.mkdir(parents=True, exist_ok=True)

    with sqlite3.connect(DB_PATH) as connection:
        for sql_path in sorted(DDL_DIR.glob("*.sql")):
            print(f"Executing DDL: {sql_path}", flush=True)
            connection.executescript(sql_path.read_text(encoding="utf-8"))

        for sql_path in sorted(QUERIES_DIR.glob("*.sql")):
            print(f"Executing query: {sql_path}", flush=True)
            cursor = connection.execute(sql_path.read_text(encoding="utf-8"))
            output_path = OUTPUTS_DIR / f"{sql_path.stem}.csv"

            with output_path.open("w", newline="", encoding="utf-8") as output_file:
                writer = csv.writer(output_file)
                writer.writerow(column[0] for column in cursor.description)
                writer.writerows(cursor)


if __name__ == "__main__":
    main()