#!/usr/bin/python3

import pandas as pd
import sys

df = pd.read_csv('movies.csv', index_col=0, usecols=[0, 1]).title
for line in sys.stdin:
    user, item, rating = line.strip().split('@')
    print(f'{user}@{df[int(item)]}@{rating}@')
