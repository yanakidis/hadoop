#!/usr/bin/python3

import numpy as np
import sys

def get_result(user, item, ratings, similarities, eps=1e-9):
    if (user is None) or (item is None):
        return
    else:
        res = np.sum(np.array(ratings)*np.array(similarities)) / (sum(similarities) + eps)
        # res = np.average(ratings, weights=similarities)
        if res > 0:
            print(f'{user}@{item}@{round(res, 3)}')

last_user = None
last_item = None
ratings = []
similarities = []
for line in sys.stdin:
    curr_user, curr_item, data = line.split('@')
    rating, sim = data.split(',')
    rating = float(rating)
    sim = float(sim)
    if (curr_user, curr_item) != (last_user, last_item):
        get_result(last_user, last_item, ratings, similarities)
        last_user = curr_user
        last_item = curr_item
        ratings = []
        similarities = []
    ratings.append(rating)
    similarities.append(sim)
get_result(curr_user, curr_item, ratings, similarities)