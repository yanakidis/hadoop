#!/usr/bin/python3
# Mapper code for matrix multiplication

import sys
import os

# number of rows in A
n = int(os.environ["number_of_rows_A"])

# number of columns in B
k = int(os.environ["number_of_columns_B"])

for line in sys.stdin:
    line = line.strip()
    elements = line.split()
    row = int(elements[0])
    col = 0
    for value in elements[1:]:
        elem = float(value)
        # if matrix is A
        if (os.environ["mapreduce_map_input_file"][-5:] == "A.txt"):
            for i in range(k):
                print('{0:d},{1:d}\t{2:d},{3:f}'.format(row, i, col, elem))
        # B
        else:
            for i in range(n):
                print('{0:d},{1:d}\t{2:d},{3:f}'.format(i, col, row, elem))
        col += 1
