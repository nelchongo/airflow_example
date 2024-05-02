# FS Airflow Documentation

Welcome to the FS Airflow Documentation. This project serves as a concise example of foundational infrastructure for standard data engineering projects, specifically designed for batch processing. In the `./dags` folder, you will find an illustrative example of data extraction from a Pokémon API, with the resulting data being stored in an Amazon S3 bucket in the form of a .csv file.

## Prerequisites
Before you can successfully utilize this project, please ensure you have the following prerequisites in place:

- docker
- docker-compose
- An active AWS account with administrative access
- Access to the main application infrastructure repository, which can be found [here](https://github.com/NelsonECandia/fs_infrastructure).

>**__NOTE:__** The main infrastructure is a private repo


## Project Structure

    root
    ├─ dags
    │   ├─ scripts
    │   │   ├─ extraction_pokemon
    │   │   │   ├─ extraction_dummy_tables.py   <<<<<<<<<<<<< Desired table structure
    │   │   │   ├─ extraction_script.py         <<<<<<<<<<<<< Connection example into a public API
    │   │   ├─ util                             <<<<<<<<<<<<< Common library for any script this can also be setup as a python module
    │   │       ├─ aws_connector.py
    │   │       ├─ requests.py
    │   ├─ extraction_poke_dag.py               <<<<<<<<<<<<< Actually AirlowDAG
    ├─ infrastructure
    │   ├─ ecs
    │   │   ├─ airflow.taskdefinition.json      <<<<<<<<<<<<< Definition of ECS Cluster for AWS Service
    │   ├─ terraform                            <<<<<<<<<<<<< Terraform Infrastructure Definition
    │       ├─ dev
    │           ├─ application.tf
    │           ├─ provider.tf
    │           ├─ s3.tf
    │           ├─ secrets.tf
    ├─ logs
    ├─ plugins
    ├─ .env
    ├─ .gitignore
    ├─ deploy.sh                                <<<<<<<<<<<<< This is for deploying the image for all the services into AWS ECR
    ├─ docker-compose.yaml
    ├─ Dockerfile                               <<<<<<<<<<<<< Custom Image Definition
    ├─ README.md
    ├─ requirements.txt                         <<<<<<<<<<<<< Requirement for custom image

How to make a [python module](https://packaging.python.org/en/latest/guides/distributing-packages-using-setuptools/)


To run this project locally just:

    docker-compose up -d

Then wait for the services to be up and running

Credentials:

    user: airflow
    password: airflow