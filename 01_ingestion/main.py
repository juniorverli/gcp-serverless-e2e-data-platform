import functions_framework
from flask import Request
from src.config import Config
from src.ingestion import TPCHIngestion

@functions_framework.http
def handler(request: Request) -> tuple[str, int]:
    config = Config()

    if not config.table_name:
        return "TPCH_TABLE_NAME environment variable not set", 400

    try:
        ingestion = TPCHIngestion(config)
        published_count = ingestion.run_single_table(config.table_name)
        return str(published_count), 200
    except ValueError as e:
        return str(e), 400

def main() -> None:
    config = Config()
    print("TPC-H Data Generator for Pub/Sub Ingestion")

    ingestion = TPCHIngestion(config)
    ingestion.run_all_tables()

    print("Ingestion complete!")

if __name__ == "__main__":
    main()
