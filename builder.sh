#!/bin/sh

test -z "$(which platformio 2>/dev/null)" && $(which pip3) install platformio

for cfg in $(ls configs/); do
	  echo Configuring ${cfg}
    cd configs/${cfg}
    for branch in $(ls); do
        git clone -b ${branch} https://github.com/MarlinFirmware/Marlin current-build
        test -e ${branch}/platformio.ini && \
            rm -fv current-build/platformio.ini && \
            cp -v ${branch}/platformio.ini current-build/
        cp -v ${branch}/*.h current-build/Marlin/
        cd current-build
        platformio run -t build
    done
    cd ../../
done
