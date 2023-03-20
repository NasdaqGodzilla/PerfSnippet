set ylabel "Mem(MB)"
set y2label "Percentage(%)"
set y2tics 0, 10, 100
set y2range [0:100]
set autoscale x
set autoscale y
set title "PerfSnippet Report(Full)"
plot DATAFILE u 1:2 axis x1y1 t "MemFree(MB)" s b lw 2, DATAFILE u 1:3 axis x1y1 t "MemAvai(MB)" s b lw 2, DATAFILE u 1:4 axis x1y2 t "CPU Usage(%)" s b lw 2, DATAFILE u 1:5 axis x1y2 t "CPU USR(%)" s b lw 2, DATAFILE u 1:6 axis x1y2 t "CPU SYS(%)" s b lw 2, DATAFILE u 1:7 axis x1y2 t "CPU Other(%)" s b lw 2, DATAFILE u 1:8 axis x1y2 t "CPU Idle(%)" s b lw 2
set title "PerfSnippet Report(CPU Usage + Mem)"
plot DATAFILE u 1:2 axis x1y1 t "MemFree(MB)" s b lw 2, DATAFILE u 1:3 axis x1y1 t "MemAvai(MB)" s b lw 2, DATAFILE u 1:4 axis x1y2 t "CPU Usage(%)" s b lw 2
