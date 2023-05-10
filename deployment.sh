#!/bin/bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 549532010890.dkr.ecr.us-east-1.amazonaws.com
docker build -t data-analytics .
docker tag data-analytics:latest 549532010890.dkr.ecr.us-east-1.amazonaws.com/data-analytics:latest
docker push 549532010890.dkr.ecr.us-east-1.amazonaws.com/data-analytics:latest

# SUBNET0=subnet-087f5af8f359211b8
# SUBNET1=subnet-03b3e610048528630
# SECURITY_GROUP=sg-0537ef8b6f87aeff1
# REVISION=$(aws ecs describe-task-definition --task-definition data-analytics | egrep \"revision\" | grep -Eo '[0-9]{1,4}')
# aws ecs --action taskrun --cluster data-analytics --taskDefinition data-analytics:${REVISION} --subnet ${SUBNET0} --subnet ${SUBNET1} --securityGroup ${SECURITY_GROUP}