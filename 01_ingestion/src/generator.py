import random
import duckdb
from faker import Faker
from src.config import Config, Constants

class FakeDataFactory:
    faker = Faker()

    @classmethod
    def random_name(cls) -> str:
        return cls.faker.name()

    @classmethod
    def random_email(cls, name: str) -> str:
        name_parts = name.lower().replace(" ", ".").replace("..", ".")
        domain = random.choice(Constants.EMAIL_DOMAINS)
        return f"{name_parts}@{domain}"

class TPCHGenerator:
    def __init__(self, config: Config):
        self.config = config
        self.connection = self._create_connection()
        self._register_udfs()
        self._generate_tpch_data()

    def _create_connection(self) -> duckdb.DuckDBPyConnection:
        connection = duckdb.connect(":memory:")
        connection.execute(f"SET memory_limit='{self.config.duckdb_memory_limit}';")
        connection.execute(f"SET threads={self.config.duckdb_threads};")
        connection.execute("INSTALL tpch; LOAD tpch;")
        return connection

    def _register_udfs(self) -> None:
        self.connection.create_function("random_name", FakeDataFactory.random_name, [], str)
        self.connection.create_function("random_email", FakeDataFactory.random_email, [str], str)

    def _generate_tpch_data(self) -> None:
        self.connection.execute(f"CALL dbgen(sf={self.config.scale_factor});")

    def _load_query(self, table_name: str) -> str:
        if table_name == "customer":
            query_file = Constants.QUERIES_DIR / "customer.sql"
        else:
            query_file = Constants.QUERIES_DIR / "default.sql"

        query_template = query_file.read_text()
        return query_template.format(table_name=table_name)

    def get_available_tables(self) -> list[str]:
        result = self.connection.execute("SHOW TABLES")
        return [row[0] for row in result.fetchall()]

    def iterate_table_as_bytes(self, table_name: str) -> Constants.MessageStream:
        query = self._load_query(table_name)

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
