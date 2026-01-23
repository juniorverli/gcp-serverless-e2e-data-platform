from src.config import Config
from src.generator import TPCHGenerator
from src.publisher import PubSubPublisher

class TPCHIngestion:
    def __init__(self, config: Config):
        self.config = config
        self.publisher = PubSubPublisher(config)

    def log_config(self) -> None:
        print(f"Configuration: project={self.config.gcp_project_id}, scale_factor={self.config.scale_factor}, batch_size={self.config.batch_size}")

    def _publish_table(self, generator: TPCHGenerator, table_name: str) -> int:
        print(f"Starting ingestion for table: {table_name}")
        row_count = generator.get_table_row_count(table_name)
        print(f"[{table_name.upper()}] {row_count} rows -> {self.publisher.get_topic_path(table_name)}")

        messages = generator.iterate_table_as_bytes(table_name)
        published_count = self.publisher.publish_batch(
            table_name=table_name,
            messages=messages,
            batch_size=self.config.batch_size,
        )

        print(f"Successfully published {published_count} records from {table_name.upper()}\n")
        return published_count

    def run_single_table(self, table_name: str) -> int:
        self.log_config()

        with TPCHGenerator(self.config) as generator:
            available_tables = generator.get_available_tables()

            if table_name not in available_tables:
                raise ValueError(f"Table '{table_name}' not found. Available: {available_tables}")

            return self._publish_table(generator, table_name)

    def run_all_tables(self) -> dict[str, int]:
        self.log_config()
        results = {}

        with TPCHGenerator(self.config) as generator:
            tables = generator.get_available_tables()
            print(f"Available TPC-H tables: {tables}\n")

            for table_name in tables:
                results[table_name] = self._publish_table(generator, table_name)

        return results
