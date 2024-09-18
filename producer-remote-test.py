from confluent_kafka import Producer
from confluent_kafka import Consumer, KafkaException, TopicPartition, KafkaError
from confluent_kafka.admin import AdminClient, NewTopic

# 1. Function push message to kafka topic
def push_message_to_kafka(message,ip,port,topic):
    bootstrap_servers = ip+":"+port

    # Kafka producer configuration
    producer_config = {
        'bootstrap.servers': bootstrap_servers
    }

    # Create a Kafka producer
    producer = Producer(producer_config)

    try:
        # Produce the message
        producer.produce(topic=topic, value=message)
        producer.flush()  # Wait for the message to be sent
        print("Message sent successfully.")
    except Exception as e:
        print(f"Failed to send message to Kafka: {e}")

# 0. Server variable
kafka_ip = "193.206.183.37" # IP machine install docker
kafka_port = "29093"
kafka_topic = "decompile-log"
push_message_to_kafka("hello from remote",kafka_ip,kafka_port,kafka_topic)