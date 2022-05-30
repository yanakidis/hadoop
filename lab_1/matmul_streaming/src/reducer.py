#!/usr/bin/python3
# Reducer code for matrix multiplication

import sys
import os

# number of columns of A/rows of B
m = int(os.environ["number_of_columns_A/rows_B"])

res = 0.0
current_key = None
dict_of_elems = dict()

for line in sys.stdin:
    line = line.strip()
    key, value = line.split('\t', 1)
    try:
        sp = key.split(',')
        row, col = map(int, sp)
        key = (row, col)
        value = value.split(',')
        additional_key, elem_value = int(value[0]), float(value[1])
    except:
        continue
    if key == current_key:
        if additional_key not in dict_of_elems:
            dict_of_elems[additional_key] = [elem_value]
        else:
            dict_of_elems[additional_key].append(elem_value)
    else:
        if current_key:
            for j in range(m):
                if (j in dict_of_elems) and (len(dict_of_elems[j]) == 2):
                    res += dict_of_elems[j][0] * dict_of_elems[j][1]
            print('{0:d},{1:d}\t{2:.5f}'.format(current_key[0], current_key[1], res))
        current_key = key
        dict_of_elems = dict()
        dict_of_elems[additional_key] = [elem_value]
        res = 0.0

if current_key:
    for j in range(m):
        if (j in dict_of_elems) and (len(dict_of_elems[j]) == 2):
            res += dict_of_elems[j][0] * dict_of_elems[j][1]
    print('{0:d},{1:d}\t{2:.5f}'.format(current_key[0], current_key[1], res))
