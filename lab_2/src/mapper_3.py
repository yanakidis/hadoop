#!/usr/bin/python3

import os
import sys

for line in sys.stdin:
    if (os.environ["mapreduce_map_input_file"][-3:] == "csv"):
        user, item, rating_ui, _ = line.strip().split(',')
        if rating_ui == 'rating':
            continue
        print(f'{item}@{user},{float(rating_ui)},T')
    else:
        base_item, data = line.strip().split('@')
        items, similarities = data.split('%')
        for item, sim in zip(items.split(','), similarities.split(',')):
            print(f'{item}@{base_item},{sim},F')

# f = open('ratings.csv', 'r')
# for line in f:
#     user, item, rating_ui, _ = line.strip().split(',')
#     if rating_ui == 'rating':
#         continue
#     print(f'{item}@{user},{float(rating_ui)},T')
#
# for line in sys.stdin:
#     base_item, data = line.strip().split('@')
#     items, similarities = data.split('%')
#     for item, sim in zip(items.split(','), similarities.split(',')):
#         print(f'{item}@{base_item},{sim},F')