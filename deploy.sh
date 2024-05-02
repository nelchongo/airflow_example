#!/bin/bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 549532010890.dkr.ecr.us-east-1.amazonaws.com
docker build -t airflow .
docker tag airflow:latest 549532010890.dkr.ecr.us-east-1.amazonaws.com/airflow:latest
docker push 549532010890.dkr.ecr.us-east-1.amazonaws.com/airflow:latest