#!/bin/bash
count=$(ps -ef | grep nginx | grep -Ecv "grep|$$")
if [ $count -eq 0 ]; then
    systemctl start nginx
    count2=$(ps -ef | grep nginx | grep -Ecv "grep|$$")
    if [ $count2 -eq 0 ]; then
        systemctl stop keepalived
    fi
fi
