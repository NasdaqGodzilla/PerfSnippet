# Init
set title "PerfSnippet Report" # 添加额外的Description到title
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
# set multiplot layout 3,1
# set pm3d
# set parametric
set autoscale x
set autoscale y

plot \
    "perfsnippet_20230314_201937.data" u 1:2 axis x1y1 t 'MemFree(MB)' s b lw 2, \
    "perfsnippet_20230314_201937.data" u 1:3 axis x1y1 t 'MemAvai(MB)' s b lw 2, \
    "perfsnippet_20230314_201937.data" u 1:4 axis x1y2 t 'CPU Usage(%)' s b lw 2, \
    "perfsnippet_20230314_201937.data" u 1:5 axis x1y2 t 'CPU USR(%)' s b lw 2, \
    "perfsnippet_20230314_201937.data" u 1:6 axis x1y2 t 'CPU SYS(%)' s b lw 2, \
    "perfsnippet_20230314_201937.data" u 1:7 axis x1y2 t 'CPU Other(%)' s b lw 2, \
    "perfsnippet_20230314_201937.data" u 1:8 axis x1y2 t 'CPU Idle(%)' s b lw 2, \

# set xrange [0:300]
# replot
# set xrange [300:600]
# replot

# Output
set size 1.0, 1.0
set term svg size 1200, 800 #"Helvetica" 16
set output 'output_perfsnippet.svg'
replot

