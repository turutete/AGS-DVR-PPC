#!/bin/bash

#lanzar servidor X: (tiny X -> kdrive: Xvesa o Xfbdev)
#Xvesa: (se ve peor que con Xfbdev)
#Xvesa -dpi 96

#Xfbdev:
#Xfbdev -dpi 88
#Xfbdev -dpi 96
#startxkd
#Xfbdev -dpi 96 -screen 640x480 -rgba rgb -nolisten tcp
#/usr/X11R6/bin/Xfbdev -dpi 96 -screen 640x480 -rgba rgb -nolisten tcp -br
/usr/X11R6/bin/Xfbdev -dpi 88 -screen 640x480 -rgba rgb -nolisten tcp -br
