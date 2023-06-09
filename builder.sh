#!/bin/sh

BASE=${PWD}
test -z "$(which platformio 2>/dev/null)" && $(which pip3) install platformio

for cfg in $(ls configs/); do
    if test "${cfg}" = "${1}"; then
	      echo Configuring ${cfg}
        cd configs/${cfg}
        for branch in $(ls); do
            echo Building for ${branch}
            git clone -b ${branch} https://github.com/MarlinFirmware/Marlin current-build
            test -e ${branch}/platformio.ini && \
                rm -fv current-build/platformio.ini && \
                cp -v ${branch}/platformio.ini current-build/
            cp -v ${branch}/*.h current-build/Marlin/
	          test -e ${branch}/environ && . ${branch}/environ
            cd current-build
            platformio run ${build_env} && \
                test -e ${build_obj} && mv -v ${build_obj} ${BASE}/${cfg}_${branch}_$(basename ${build_obj})
            cd ../ && rm -rf current-build
        done
        cd ../../
    fi
done
