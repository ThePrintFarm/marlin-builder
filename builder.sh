#!/bin/sh

set -e

BASE=${PWD}
MARLIN_REPO=https://github.com/MarlinFirmware/Marlin
BUILD_DIR="${PWD}/marlin-build-dir"
test -z "$(which platformio 2>/dev/null)" && $(which pip3) install platformio

test ! -d ${BUILD_DIR} && git clone ${MARLIN_REPO} ${BUILD_DIR}
cd configs/
for vendor in $(ls ${BASE}/configs/); do
    if test "${vendor}" = "${1}"; then
        cd ${BASE}/configs/${vendor}
        for model in $(ls); do
            cd ${model}
            for board in $(ls); do
                cd ${board}
                for branch in $(ls); do
                    cd ${branch}
                    for flavor in $(ls); do
                        build_obj=""
                        build_env=""
                        build_out="${vendor}__${model}__${board}__${branch}__${flavor}__$(date +%m%d%Y-%H%M%S)"
                        trail="${BASE}/configs/${vendor}/${model}/${board}/${branch}/${flavor}"
                        cd ${BUILD_DIR}
                        git stash && git checkout ${branch} && git pull
                        if test -e ${trail}/platformio.ini; then
                            rm -fv ${BUILD_DIR}/platformio.ini
                            cp -v ${trail}/platformio.ini ${BUILD_DIR}/
                        fi
                        cp -v ${trail}/*.h ${BUILD_DIR}/Marlin/
                        test -e ${trail}/inputs && . ${trail}/inputs
                        test -d ${trail}/ini && cp -av ${trail}/ini/* ${BUILD_DIR}/ini/
                        echo "DEBUG: ${build_out}"
                        if test -z "${build_obj}"; then
                            # this is kind of brittle
                            set -x
                            build_obj=$(platformio run ${build_env}|tee|grep -e '^Building .pio.*$'|awk '{print $2}')
                            set +x
                        else
                            platformio run ${build_env} 2>&1 >/tmp/build.log && rm -f /tmp/build.log || cat /tmp/build.log
                        fi
                        echo "DEBUG: ${build_obj}"
                        mv -v ${build_obj} ${BASE}/${build_out}__$(basename ${build_obj})
                        platformio run ${build_env} -t clean
                        cd ${BASE}/configs/${vendor}/${model}/${board}/${branch}
                    done
                    cd ..
                done
                cd ..
            done
            cd ..
        done
        cd ..
    fi
done
rm -rf ${BUILD_DIR}

