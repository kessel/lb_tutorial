echo "f(x)=a*x+b; fit [100:] f(x) \"$1\" via a,b; print \"fit: \", a, b;" | gnuplot 2>&1 | grep fit: | cut -d ":" -f 2