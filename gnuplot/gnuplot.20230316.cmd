# Usage: gnuplot -c gnuplot.20230316.cmd perfsnippet_20230314_201937.data
# ARG0: Script file
# ARG1: Data file

# Init
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

# Mem
set ylabel "Mem(MB)"

# CPU
set y2label "Percentage(%)"
set y2tics 0, 10, 100
set y2range [0:100]

# Render
set size 1.0, 1.0
set term svg size 1000, 2000 #"Helvetica" 16
set output sprintf("output_%s@%s.svg", ARG1, strftime('%Y%m%d_%H%M%S', time(0)))
set multiplot layout 5,1
set autoscale x
set autoscale y

## Full
set title "PerfSnippet Report(Full)"
plot \
    ARG1 u 1:2 axis x1y1 t 'MemFree(MB)' s b lw 2, \
    ARG1 u 1:3 axis x1y1 t 'MemAvai(MB)' s b lw 2, \
    ARG1 u 1:4 axis x1y2 t 'CPU Usage(%)' s b lw 2, \
    ARG1 u 1:5 axis x1y2 t 'CPU USR(%)' s b lw 2, \
    ARG1 u 1:6 axis x1y2 t 'CPU SYS(%)' s b lw 2, \
    ARG1 u 1:7 axis x1y2 t 'CPU Other(%)' s b lw 2, \
    ARG1 u 1:8 axis x1y2 t 'CPU Idle(%)' s b lw 2, \

## Mem
### CPU Usage + MemFree + MemAvai
set title "PerfSnippet Report(CPU Usage + Mem)"
plot \
    ARG1 u 1:2 axis x1y1 t 'MemFree(MB)' s b lw 2, \
    ARG1 u 1:3 axis x1y1 t 'MemAvai(MB)' s b lw 2, \
    ARG1 u 1:4 axis x1y2 t 'CPU Usage(%)' s b lw 2, \

### MemFree
set title "PerfSnippet Report(MemFree)"
plot \
    ARG1 u 1:2 axis x1y1 t 'MemFree(MB)' s b lw 2, \

### MemAvai
set title "PerfSnippet Report(MemAvai)"
plot \
    ARG1 u 1:3 axis x1y1 t 'MemAvai(MB)' s b lw 2, \

## CPU
### CPU Details
set title "PerfSnippet Report(CPU)"
plot \
    ARG1 u 1:4 axis x1y2 t 'CPU Usage(%)' s b lw 2, \
    ARG1 u 1:5 axis x1y2 t 'CPU USR(%)' s b lw 2, \
    ARG1 u 1:6 axis x1y2 t 'CPU SYS(%)' s b lw 2, \
    ARG1 u 1:7 axis x1y2 t 'CPU Other(%)' s b lw 2, \

### Split
# set xrange [0:300]
# replot
# set xrange [300:600]
# replot

