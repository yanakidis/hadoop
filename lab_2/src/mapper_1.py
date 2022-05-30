#!/usr/bin/python3

import sys

for line in sys.stdin:
    user, item, rating_ui, _ = line.strip().split(',')
    if rating_ui == 'rating':
        continue
    print(f'{user}@{item}%{float(rating_ui)}')
