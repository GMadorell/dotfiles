#!/bin/zsh
# Messaging service aliases: Zookeeper, Kafka, RabbitMQ

## Zookeeper aliases
ZOOKEEPER_URL="localhost:2181"
alias zkcli="zkCli"
### TODO zk_random_broker doesn't work with >1 brokers, need to split the string
function zk_random_broker() { zk <<< "ls /brokers/ids" | tail -n 2 | head -n 1 | trim "[]" ; }

## Kafka aliases
function kafka_list_topics() { kafka-topics --zookeeper $ZOOKEEPER_URL --list ; }
function kafka_delete_topic() {
  if [ $# -eq 1 ]; then
      kafka-topics --zookeeper $ZOOKEEPER_URL --delete --topic $1
  else
      echo "$LOG_ERROR Usage: kafka_delete_topic <TOPIC_NAME>"
  fi
}
function kafka_describe_topic() {
  if [ $# -eq 1 ]; then
      kafka-topics --zookeeper $ZOOKEEPER_URL --describe --topic $1
  else
      echo "$LOG_ERROR Usage: kafka_describe_topic <TOPIC_NAME>"
  fi
}
function kafka_create_topic() {
  if [ $# -eq 1 ]; then
      kafka-topics --zookeeper $ZOOKEEPER_URL --create --topic $1 --partitions 1 --replication-factor 1
  else
      echo "$LOG_ERROR Usage: kafka_create_topic <TOPIC_NAME>"
  fi
}

# RabbitMQ aliases
function rabbitinit() { brew services run rabbitmq ; }
function rabbitstop() { brew services stop rabbitmq ; }
function rabbitrestart() { brew services restart rabbitmq ; }
function rabbit_list_queues() { rabbitmqadmin list queues ; }
function rabbitcheck() { rabbit_list_queues ; }
