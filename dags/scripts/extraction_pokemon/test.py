import numpy as np
from multiprocessing import Pool, cpu_count

total = 100
limit = 10
offset_list = np.array(list(range(limit))) * limit

offset_list