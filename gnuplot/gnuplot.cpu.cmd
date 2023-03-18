set title "PerfSnippet Report(CPU)"
set y2label "Percentage(%)"
set y2tics 0, 10, 100
set y2range [0:100]
plot DATAFILE u 1:4 axis x1y2 t "CPU Usage(%)" s b lw 2, DATAFILE u 1:5 axis x1y2 t "CPU USR(%)" s b lw 2, DATAFILE u 1:6 axis x1y2 t "CPU SYS(%)" s b lw 2, DATAFILE u 1:7 axis x1y2 t "CPU Other(%)" s b lw 2
