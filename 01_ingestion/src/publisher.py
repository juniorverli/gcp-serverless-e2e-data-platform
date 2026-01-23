from typing import Iterator
from google.cloud import pubsub_v1
from src.config import Config

class PubSubPublisher:
    def __init__(self, config: Config):
        self.config = config
        self.client = pubsub_v1.PublisherClient()

    def get_topic_path(self, table_name: str) -> str:
        topic_name = f"{self.config.pubsub_topic_prefix}-{table_name}"
        return self.client.topic_path(self.config.gcp_project_id, topic_name)

    def publish_batch(self, table_name: str, messages: Iterator[bytes], batch_size: int) -> int:
        topic_path = self.get_topic_path(table_name)
        futures = []
        published_count = 0

        for message in messages:
            future = self.client.publish(
                topic_path,
                message,
                table_name=table_name,
            )
            futures.append(future)
            published_count += 1

            if len(futures) >= batch_size:
                for f in futures:
                    f.result()
                futures = []

        for f in futures:
            f.result()

        return published_count
