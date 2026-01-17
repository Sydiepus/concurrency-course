#!/bin/bash
set -e

COMPOSE_FILE="/workspace/tools/docker-compose.yml"
DC="docker compose -f $COMPOSE_FILE"

case "$1" in
  start)
    echo "Starting Kafka cluster..."
    $DC up -d zookeeper kafka

    echo -n "Waiting for Kafka"
    for i in {1..30}; do
      if $DC exec -T kafka kafka-broker-api-versions --bootstrap-server localhost:9092 >/dev/null 2>&1; then
        echo ""
        echo "Kafka is ready."
        $DC up -d kafka-ui
        echo "Kafka UI: http://localhost:8080"
        echo "Broker:   localhost:9092"
        echo "Test:     ./scripts/kafka-quickstart.sh topics"
        exit 0
      fi
      printf "."
      sleep 2
    done

    echo ""
    echo "Kafka failed to start within 60 seconds."
    echo "Try: ./scripts/kafka-quickstart.sh reset"
    exit 1
    ;;

  stop)
    echo "Stopping Kafka cluster..."
    $DC stop kafka kafka-ui zookeeper
    echo "Kafka stopped."
    ;;

  reset)
    echo "Resetting Kafka (deleting all data)..."
    $DC down -v
    $DC up -d zookeeper kafka
    sleep 5
    $DC up -d kafka-ui
    echo "Kafka reset complete."
    ;;

  status)
    echo "Kafka cluster status:"
    $DC ps zookeeper kafka kafka-ui
    echo ""
    if $DC exec -T kafka kafka-topics --bootstrap-server localhost:9092 --list >/dev/null 2>&1; then
      echo "Kafka is responding."
    else
      echo "Kafka not responding."
    fi
    ;;

  logs)
    echo "Kafka logs (last 50 lines):"
    $DC logs --tail=50 kafka
    ;;

  topics)
    echo "Kafka topics:"
    $DC exec -T kafka kafka-topics --bootstrap-server localhost:9092 --list
    ;;

  create-topic)
    if [ -z "$2" ]; then
      echo "Usage: $0 create-topic <topic-name>"
      exit 1
    fi
    echo "Creating topic: $2"
    $DC exec -T kafka kafka-topics --create \
      --topic "$2" \
      --bootstrap-server localhost:9092 \
      --partitions 1 \
      --replication-factor 1
    echo "Topic created."
    ;;

  *)
    echo "Usage: $0 {start|stop|reset|status|logs|topics|create-topic}"
    exit 1
    ;;
esac
