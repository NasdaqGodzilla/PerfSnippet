set ylabel "FPS"
set title "PerfSnippet Report(Frame Rate)"
plot DATAFILE u 1:9 axis x1y1 t 'FPS' s b lw 2
