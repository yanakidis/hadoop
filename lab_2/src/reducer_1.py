#!/usr/bin/python3

import sys

last_user = None
user_items = []
user_ratings = []
for line in sys.stdin:
    curr_user, data = line.strip().split('@')
    item, rating_ui = data.split('%')
    if curr_user != last_user:
        if last_user is not None:
            user_items = ','.join(user_items)
            user_ratings = ','.join(user_ratings)
            print(f'{last_user}@{user_items}%{user_ratings}')
        last_user = curr_user
        user_items = []
        user_ratings = []
    user_items.append(item)
    user_ratings.append(rating_ui)
user_items = ','.join(user_items)
user_ratings = ','.join(user_ratings)
print(f'{curr_user}@{user_items}%{user_ratings}')
