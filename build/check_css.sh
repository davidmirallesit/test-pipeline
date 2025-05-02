#!/usr/bin/sh
for i in `cat gulp/config-sass.json | grep -E "\.(scss|css)" | sed 's/[",]//g' | sed -E 's/(^ +| +$)//'`;do ls -lh "$i";done
