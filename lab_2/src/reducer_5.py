#!/usr/bin/python3

import sys

last_user = None
top_movies = []
n = 100

for line in sys.stdin:
    curr_user, movie_name, rating, _ = line.strip().split('@')
    if curr_user == last_user:
        if len(top_movies) == n:
            continue
        else:
            top_movies.append(f'{round(float(rating)/5, 3)}%{movie_name}')
            if len(top_movies) == n:
                print(f'{last_user}@{"@".join(top_movies)}')
    else:
        last_user = curr_user
        top_movies = []
        top_movies.append(f'{round(float(rating)/5, 3)}%{movie_name}')