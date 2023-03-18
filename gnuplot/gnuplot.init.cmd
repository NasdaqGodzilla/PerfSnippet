set xlabel "second(s)"
set grid
set key box
set key Left
set key right top #font "Helvetica,6"
set xtics
set ytics
set mxtics 5
set mytics 10
set font 'Times New Roman,6'
set timestamp
set style fill solid 0.66
set boxwidth 0.50
set autoscale x
set autoscale y
set size 1.0, 1.0
set output sprintf("output_%s@%s.svg", ARG1, strftime('%Y%m%d_%H%M%S', time(0)))
