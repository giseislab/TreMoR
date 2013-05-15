#!/bin/tcsh
date
echo "Hard drive space"
df -h .
echo "Hard drive space used by spectrograms (kB)"
du -sh spectrograms
echo "MATLAB processes running in order of CPU usage"
ps -elm | grep matlab | grep -v grep | awk '{print $2,$3,$5,$14,$15,$16,$17,$18,$19,$20,$21,$22}'
