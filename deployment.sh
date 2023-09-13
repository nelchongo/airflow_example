#!/bin/bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 549532010890.dkr.ecr.us-east-1.amazonaws.com
docker build -t airflow .
docker tag airflow:latest 549532010890.dkr.ecr.us-east-1.amazonaws.com/airflow:latest
docker push 549532010890.dkr.ecr.us-east-1.amazonaws.com/airflow:latest

# SUBNET0=subnet-0c96439cc947268d3
# SECURITY_GROUP=sg-0ac2a0618d01846eb
# REVISION=$(aws ecs describe-task-definition --task-definition airflow | egrep \"revision\" | grep -Eo '[0-9]{1,4}')
# aws ecs run-task --task-definition airflow:${REVISION} --cluster airflow --count 1 --network-configuration "awsvpcConfiguration={subnets=["${SUBNET0}"],securityGroups=["${SECURITY_GROUP}"]}" --enable-execute-command