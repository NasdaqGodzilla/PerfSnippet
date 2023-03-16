# Init
set title "PerfSnippet Report" # 添加额外的Description到title
set xlabel "second(s)"

# Mem
set ylabel "Mem(MB)"

# CPU
set y2label "Percentage(%)"

# Output

# Render
plot \
    "perfsnippet_20230314_201937.data" u 1:2 axis x1y1 t 'MemFree(MB)' s b, \
    "perfsnippet_20230314_201937.data" u 1:3 axis x1y1 t 'MemAvai(MB)' s b, \
    "perfsnippet_20230314_201937.data" u 1:4 axis x1y2 t 'CPU Usage(%)' s b, \
    "perfsnippet_20230314_201937.data" u 1:5 axis x1y2 t 'CPU USR(%)' s b, \
    "perfsnippet_20230314_201937.data" u 1:6 axis x1y2 t 'CPU SYS(%)' s b, \
    "perfsnippet_20230314_201937.data" u 1:7 axis x1y2 t 'CPU Other(%)' s b, \
    "perfsnippet_20230314_201937.data" u 1:8 axis x1y2 t 'CPU Idle(%)' s b, \

