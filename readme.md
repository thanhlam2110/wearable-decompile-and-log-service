## 1. Introduction

The **(SL)-system-log** is part of the **REALME** system architecture.

This service is used to store and display system logs:

**Service Logs → Kafka Message Queue → Logstash → Elastic Search → Kibana**.

<img src="https://github.com/research-mobile-security/REALME/blob/main/(SL)-system-log/readme-image/metaLeak-ml-overview.png">

## 2. Source code
Edit the IP address with your host IP in the line below in the `docker-compose.yml` file to access Kafka remotely

```bash
[From]
KAFKA_ADVERTISED_LISTENERS: INTERNAL://kafka-cntr:9092,EXTERNAL_SAME_HOST://localhost:29092,EXTERNAL_DIFFERENT_HOST://192.168.1.20:29093
[To]
KAFKA_ADVERTISED_LISTENERS: INTERNAL://kafka-cntr:9092,EXTERNAL_SAME_HOST://localhost:29092,EXTERNAL_DIFFERENT_HOST://your-host-IP:29093
```
## 3. How to run?

```bash
[Build container]
docker-compose up -d
ufw allow 5601
ufw allow 5044
ufw allow 9200
ufw allow 9300
ufw allow 9092
ufw allow 29092
```

```bash
[Run test on host machine]
Test Commands for the topicname 'decompile-log' :
docker exec -it kafka-cntr bash /bin/kafka-topics --list --bootstrap-server localhost:9092
docker exec -it kafka-cntr bash /bin/kafka-console-consumer --topic decompile-log --from-beginning --bootstrap-server localhost:9092
docker exec -it kafka-cntr bash /bin/kafka-console-producer --topic decompile-log --bootstrap-server localhost:9092
```

```bash
[Run test on remote machine]
python3 producer-remote-test.py
```