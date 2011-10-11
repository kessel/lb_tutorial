#!/bin/bash
echo "f(x)=a; fit f(x) \"$1\" u 1:2 via a; print \"fit: \", a;" | gnuplot 2>&1 | grep fit: | cut -d " " -f 2
