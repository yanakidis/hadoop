#!/usr/bin/python3

import numpy as np
import sys

class Rating:
    def __init__(self):
        self.i = []
        self.j = []

def get_sim(rating_object, eps=1e-9):
    if len(rating_object.i) == 1:
        return int(rating_object.i[0] * rating_object.j[0] > 0)
    else:
        return np.dot(rating_object.i, rating_object.j) / (np.sqrt(sum(np.square(rating_object.i))
                                                              * sum(np.square(rating_object.j))) + eps)

def get_result(i, data):
    pairs = dict()
    for info in data:
        item_rating, items, ratings = info.split('%')
        items = items.split(',')
        ratings = np.array(ratings.split(','), dtype=np.float32)
        item_rating = float(item_rating)
        for j, rating in zip(items, ratings):
            if j not in pairs:
                pairs[j] = Rating()
            pairs[j].i.append(item_rating)
            pairs[j].j.append(rating)
    items = []
    similarities = []
    for j, pair in pairs.items():
        sim_ij = get_sim(pair)
        if sim_ij > 0:
            items.append(j)
            similarities.append(str(round(sim_ij, 3)))
    if len(items) > 0:
        print(f"{i}@{','.join(items)}%{','.join(similarities)}")

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
