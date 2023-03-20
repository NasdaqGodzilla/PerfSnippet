# PerfSnippet

Performance Snippet. 性能片段。

通过adb shell脚本，收集Android性能数据，输出csv格式文件，通过gnuplot绘图展示

Collect Android performance data via adb shell script, output the data in CSV format, and display it drawing by gnuplot.

# Feature

- 收集CPU/内存使用数据
- TODO：收集FPS/Network/LoadAver使用数据
- 记录数据到一个易于阅读或处理的CSV格式文件
- 通过gnuplot将数据绘制为图表

- Collect CPU/MEM usage
- TODO: Collect FPS/Network/LoadAver usage
- Record performance data to a file, which has a CSV format that is easily readable by humans or processed by computer programing language
- Plots data as a chart using gnuplot

# Example

A typical data file that PerfSnippet collected and recorded:

![](https://cdn.jsdelivr.net/gh/NasdaqGodzilla/PeacePicture/img/PerfSnippet_README_data.png)

Draws to charts by gnuplot:

![](https://cdn.jsdelivr.net/gh/NasdaqGodzilla/PeacePicture/img/output_perfsnippet_20230320_160624.data@20230320_081636.svg)

# LICENSE

Copyright (C) <2022> NiKo Zhong

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

