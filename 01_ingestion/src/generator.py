import duckdb
from src.config import Config, MessageStream

class TPCHGenerator:
    def __init__(self, config: Config):
        self.config = config
        self.connection = self._create_connection()
        self._generate_tpch_data()

    def _create_connection(self) -> duckdb.DuckDBPyConnection:
        connection = duckdb.connect(":memory:")
        connection.execute(f"SET memory_limit='{self.config.duckdb_memory_limit}';")
        connection.execute(f"SET threads={self.config.duckdb_threads};")
        connection.execute("INSTALL tpch; LOAD tpch;")
        return connection

    def _generate_tpch_data(self) -> None:
        self.connection.execute(f"CALL dbgen(sf={self.config.scale_factor});")

    def get_available_tables(self) -> list[str]:
        result = self.connection.execute("SHOW TABLES")
        return [row[0] for row in result.fetchall()]

    def iterate_table_as_bytes(self, table_name: str) -> MessageStream:
        query = f"""
            SELECT json_object(
                'data', to_json(t),
                'generated_at', strftime(now() AT TIME ZONE 'UTC', '%Y-%m-%dT%H:%M:%SZ')
            ) AS payload
            FROM {table_name} AS t
        """

        result = self.connection.execute(query)

        while True:
            rows = result.fetchmany(self.config.batch_size)
            if not rows:
                break

            for row in rows:
                yield row[0].encode("utf-8")

    def get_table_row_count(self, table_name: str) -> int:
        result = self.connection.execute(f"SELECT COUNT(*) FROM {table_name}")
        return result.fetchone()[0]

    def close(self) -> None:
        self.connection.close()

    def __enter__(self) -> "TPCHGenerator":
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        self.close()
