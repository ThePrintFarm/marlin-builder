#!/bin/sh

BASE=${PWD}
test -z "$(which platformio 2>/dev/null)" && $(which pip3) install platformio

git clone --mirror https://github.com/MarlinFirmware/Marlin /tmp/marlin-mirror
for cfg in $(ls configs/); do
    if test "${cfg}" = "${1}"; then
	      echo Configuring ${cfg}
        cd configs/${cfg}
        for branch in $(ls); do
            cd ${branch}
            for flavor in $(ls); do
                echo Building for ${cfg}-${branch}-${flavor}
                git clone -b ${branch} /tmp/marlin-mirror current-build
                test -e ${flavor}/platformio.ini && \
                    rm -fv current-build/platformio.ini && \
                    cp -v ${flavor}/platformio.ini current-build/
                cp -v ${flavor}/*.h current-build/Marlin/
	              test -e ${flavor}/environ && . ${flavor}/environ
                cd current-build
                platformio run ${build_env} && \
                    test -e ${build_obj} && mv -v ${build_obj} ${BASE}/${cfg}__${branch}__${flavor}__${REPO_TAG}__$(basename ${build_obj})
                cd ../ && rm -rf current-build
            done
        done
        cd ../../
    fi
done
