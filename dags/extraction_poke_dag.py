from airflow import DAG
from airflow import AirflowException
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

#DAG related files
from scripts.extraction_pokemon import extraction_dummy_tables
from scripts.extraction_pokemon import extraction_script

def dynamic_extraction_from_api(table):
    return PythonOperator(
        task_id="extraction_pokemon_table_{}".format(table['name']),
        execution_timeout=timedelta(minutes=15),
        python_callable=extraction_script.table_processing,
        provide_context=True,
        op_kwargs={'table': table},
        dag=dag
    )

default_args = {
    'owner': 'its me Im the problem is me',
    'depends_on_past': True,
    'start_date': datetime(2024, 2, 2, 0, 0, 0),
    'email': ['Yes i did use a taylor swift song'],
    'email_on_failure': 'no theres no problem',
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG('extraction_pokemon', default_args=default_args, max_active_runs=1, schedule_interval='0 * * * *')

start = DummyOperator(task_id='Start', dag=dag)
end = DummyOperator(task_id='End', dag=dag)

table_list = extraction_dummy_tables.TABLES

for table in table_list:
    start >> dynamic_extraction_from_api(table) >> end