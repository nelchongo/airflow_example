import sys
from pathlib import Path
sys.path.append("..")

import pandas as pd
import numpy as np
from multiprocessing import Process, Pool, cpu_count
from util.requests import requests_class
from util.aws_connector import aws_connector

script_url = "https://pokeapi.co/api/v2/"
poke_r = requests_class(script_url)
aws = aws_connector('fs-data-terraform-dev', 'pokemon')

def get_berries():
    #Berry main url
    url = "berry/"
    r = poke_r.get_response(url)
    r = pd.DataFrame(r['results'])

    #Clean URL to reuse in class
    berries = r.apply(poke_r.iter_get_response, field = 'url', axis=1)
    berries = pd.json_normalize(berries)
    print(berries)

def get_pokemons(offset:int = 0, limit:int = 0):
    #Berry main url
    url = f"pokemon/?offset={offset}&limit={limit}"
    r = poke_r.get_response(url)
    if r != 'error':
        r = pd.DataFrame(r['results'])

        #Clean URL to reuse in class
        pokemons = r.apply(poke_r.iter_get_response, field = 'url', axis=1)
        pokemons = pd.json_normalize(pokemons)
        return pokemons

if __name__ == "__main__":
    total = 100
    limit = 1 if (round(total / cpu_count() - 1)) < 1 else round(total / (cpu_count() - 2))
    offset_list = np.array(list(range(round(total/limit)))) * limit

    pool = Pool(cpu_count() - 1)
    async_results = [pool.apply_async(get_pokemons, args=(i, limit)) for i in offset_list]
    results = pd.concat([ar.get() for ar in async_results])
    pool.close()
    pool.join()
    results = results[['id', 'name', 'base_experience', 'height', 'abilities', 'forms', 'game_indices', 'types', 'stats']]

    aws.put_s3_csv(results, 'pokemon.csv')
    