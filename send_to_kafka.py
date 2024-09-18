from kafka import KafkaProducer
import sys

def send_kafka_message(broker, topic, message):
    # Initialize Kafka producer
    producer = KafkaProducer(bootstrap_servers=broker)

    # Send message to Kafka topic
    producer.send(topic, message.encode('utf-8'))
    producer.flush()  # Ensure all messages are sent

    print(f"Sent message to Kafka topic '{topic}': {message}")

if __name__ == "__main__":
    # Accept arguments for broker, topic, and message from command line
    if len(sys.argv) != 4:
        print("Usage: python send_to_kafka.py <broker> <topic> <message>")
        sys.exit(1)

    broker = sys.argv[1]
    topic = sys.argv[2]
    message = sys.argv[3]

    send_kafka_message(broker, topic, message)
