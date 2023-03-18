set ylabel "Mem(MB)"
set title "PerfSnippet Report(MemFree)"
plot DATAFILE u 1:2 axis x1y1 t 'MemFree(MB)' s b lw 2
set title "PerfSnippet Report(MemAvai)"
plot DATAFILE u 1:3 axis x1y1 t 'MemAvai(MB)' s b lw 2
