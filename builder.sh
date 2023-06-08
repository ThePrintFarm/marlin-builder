#!/bin/sh

echo $(which pip3)
echo $(which gcc)
for cfg in configs/*; do
	echo ${cfg}
done
