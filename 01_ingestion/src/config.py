import os
from typing import Iterator

MessageStream = Iterator[bytes]

class Config:
    def __init__(self):
        self.gcp_project_id = os.getenv("GCP_PROJECT_ID")
        self.batch_size = int(os.getenv("BATCH_SIZE", "1000"))
        self.scale_factor = float(os.getenv("SCALE_FACTOR", "0.001"))
        self.pubsub_topic_prefix = os.getenv("TPCH_PUBSUB_TOPIC_PREFIX", "tpch")
        self.table_name = os.getenv("TPCH_TABLE_NAME")
        self.duckdb_memory_limit = os.getenv("DUCKDB_MEMORY_LIMIT", "512MB")
        self.duckdb_threads = int(os.getenv("DUCKDB_THREADS", str(os.cpu_count())))
