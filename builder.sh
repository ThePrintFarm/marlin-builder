#!/bin/sh

test -z "$(which platformio 2>/dev/null)" && $(which pip3) install platformio
for cfg in $(ls configs/); do
	echo ${cfg}
done
