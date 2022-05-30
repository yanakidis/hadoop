#!/usr/bin/python3

import numpy as np
import sys

def get_result(i, data):
    users = []
    ratings = []

    items = []
    similarities = []
    for info in data:
        a, b, key = info.split(',')
        if key == 'T': # ratings.csv
            users.append(a)
            ratings.append(float(b))
        else:
            items.append(a)
            similarities.append(float(b))
    for user, rating in zip(users, ratings):
        for item, sim in zip(items, similarities):
            print(f'{user}@{item}@{rating if item != i else -np.inf},{sim}')

last_i = None
last_data = []
for line in sys.stdin:
    curr_i, curr_data = line.strip().split('@')
    if curr_i != last_i:
        get_result(last_i, last_data)
        last_i = curr_i
        last_data = []
    last_data.append(curr_data)
get_result(curr_i, last_data)
