#!/bin/bash

if pgrep -x cava >/dev/null; then
    killall cava
else
    cava -p ~/.config/cava/config1 | sed -u \
        -e 's/;//g' \
        -e 's/0/▁/g' \
        -e 's/1/▂/g' \
        -e 's/2/▃/g' \
        -e 's/3/▄/g' \
        -e 's/4/▅/g' \
        -e 's/5/▆/g' \
        -e 's/6/▇/g' \
        -e 's/7/█/g'
fi
