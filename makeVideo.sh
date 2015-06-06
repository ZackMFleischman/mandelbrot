#!/bin/sh
ffmpeg -start_number 1 -i frames/mandelbrot_%d.jpg -qscale:v 1 -vcodec mpeg4 MandelbrotZoom.avi
