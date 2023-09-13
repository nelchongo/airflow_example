import numpy as np
import pandas as pd
from scripts.util.requests import requests_class
from multiprocessing import Pool, cpu_count
from scripts.util.aws_connector import aws_connector

script_url = "https://pokeapi.co/api/v2/"
request_c = requests_class(script_url)
aws = aws_connector('fs-data-terraform-dev', 'pokemon')

def get_data(url, offset:int = 0, limit:int = 0):
    #Berry main url
    r = request_c.get_response(url.format(offset, limit))
    if r != 'error':
        r = pd.DataFrame(r['results'])
        #Clean URL to reuse in class
        results = r.apply(request_c.iter_get_response, field = 'url', axis=1)
        results = pd.json_normalize(results)
        return results

def offset_processing(table):
    #divide number of queries by CPUs to optimized and properly distribute the load
    total = 100
    limit = 10
    offset_list = np.array(list(range(round(total/limit)))) * limit

    results = []
    for off in offset_list:
        results.append(get_data(table["url"], off, limit))

    results = pd.concat(results)
    return results

def offset_processing_pool(table):
    #divide number of queries by CPUs to optimized and properly distribute the load
    total = 100
    limit = 1 if (round(total / cpu_count() - 1)) < 1 else round(total / (cpu_count() - 2))
    offset_list = np.array(list(range(round(total/limit)))) * limit

    #Parallel processing
    pool = Pool(cpu_count() - 1)
    async_results = [pool.apply_async(get_data, args=(table["url"],i, limit)) for i in offset_list]
    results = pd.concat([ar.get() for ar in async_results])
    pool.close()
    pool.join()

    return results

def table_processing(table):
    if table["offset"] == True:
        print("TEST")
        results = offset_processing(table)
    else:
        results = get_data(table["url"])

    #Selecting selected fields for tables
    if table['selected_fields'] != []:
        results = results[table['selected_fields']]
    aws.put_s3_csv(results, '{}.csv'.format(table['name']))

# #TESTING PURPOSE
# from extraction_dummy_tables import TABLES

# if __name__ == "__main__":
#     for table in TABLES:
#         table_processing(table)