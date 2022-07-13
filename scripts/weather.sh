#!/bin/bash

loc="lan"
let loop=0
while true; do
        if [[ $loop%300 -eq 0 ]]; then
                echo $(curl wttr.in/${loc}?format=1)
                let loop=0
        fi
        loop+=1
        sleep 1
done
#echo $(curl wttr.in/${loc}?format=2)
