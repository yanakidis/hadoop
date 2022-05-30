#!/usr/bin/python3

import numpy as np
import sys

# i = 0
for line in sys.stdin:
    user, data = line.strip().split('@')
    user_items, user_ratings = data.split('%')
    user_ratings = np.array(user_ratings.split(','), dtype=np.float32)
    user_ratings_new = (user_ratings - user_ratings.mean()).round(3).astype(str) # rating - mean
    ratings_new_all = ','.join(user_ratings_new)
    for item, rating in zip(user_items.split(','), user_ratings_new):
        print(f'{item}@{rating}%{user_items}%{ratings_new_all}')
    # i += 1
    # if i == 3:
    #     break
