#!/bin/sh

# TODO: rewrite this in python, make it readable and maintainable.

set -e

echo "${@}"
BASE=${PWD}
MARLIN_REPO=https://github.com/MarlinFirmware/Marlin
BUILD_DIR="${PWD}/marlin-build-dir"
test -z "$(which platformio 2>/dev/null)" && $(which pip3) install platformio

RUN_VENDOR="any"
RUN_MODEL="any"
RUN_BOARD="any"
RUN_BRANCH="any"
RUN_FLAVOR="any"

show_help() {
    printf "Usage: %s [-v VENDOR] [-m MODEL] [-b BOARD] [-r BRANCH] [-f FLAVOR]\n" "$(basename ${0})"
    exit 1
}

test ! -d ${BUILD_DIR} && git clone ${MARLIN_REPO} ${BUILD_DIR}

while getopts 'v:m:b:r:f:' opt; do
    case "${opt}" in
        v) RUN_VENDOR="${OPTARG}" ;;
        m) RUN_MODEL="${OPTARG}" ;;
        b) RUN_BOARD="${OPTARG}" ;;
        r) RUN_BRANCH="${OPTARG}" ;;
        f) RUN_FLAVOR="${OPTARG}" ;;
        *) show_help ;;
    esac
done

cd ${BASE}/configs
for vendor in $(ls); do
    if test "${RUN_VENDOR}" = "any" || test "${vendor}" = "${RUN_VENDOR}"; then
        cd ${BASE}/configs/${vendor}
        for model in $(ls); do
            if test "${RUN_MODEL}" = "any" || test "${model}" = "${RUN_MODEL}"; then
                cd ${model}
                for board in $(ls); do
                    if test "${RUN_BOARD}" = "any" || test "${board}" = "${RUN_BOARD}"; then
                        cd ${board}
                        for branch in $(ls); do
                            if test "${RUN_BRANCH}" = "any" || test "${branch}" = "${RUN_BRANCH}"; then
                                cd ${branch}
                                for flavor in $(ls); do
                                    if test "${RUN_FLAVOR}" = "any" || test "${flavor}" = "${RUN_FLAVOR}"; then
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
                                        if test -z "${build_obj}"; then                                   # this is kind of brittle
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
                                    fi
                                done
                                cd ..
                            fi
                        done
                        cd ..
                    fi
                done
                cd ..
            fi
        done
        cd ..
    fi
done
rm -rf ${BUILD_DIR}
