import numpy as np
import pandas as pd
from scripts.util.requests import requests_class
from multiprocessing import Pool, cpu_count
from scripts.util.aws_connector import aws_connector

request_c = requests_class("https://pokeapi.co/api/v2/")
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
    offset_list = np.arange(0, total, limit)

    results = []
    for off in offset_list:
        results.append(get_data(table["url"], off, limit))

    results = pd.concat(results)
    return results

def table_processing(table):
    if table["offset"] == True:
        results = offset_processing(table)
    else:
        results = get_data(table["url"])

    #Selecting selected fields for tables
    if table['selected_fields'] != []:
        results = results[table['selected_fields']]
    print(results)
    # aws.put_s3_csv(results, '{}.csv'.format(table['name']))