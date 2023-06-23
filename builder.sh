#!/bin/sh

# TODO: rewrite this in python, make it readable and maintainable.

set -e

BASE=${PWD}
MARLIN_REPO=https://github.com/MarlinFirmware/Marlin
BUILD_DIR="${PWD}/marlin-build-dir"
test -z "$(which platformio 2>/dev/null)" && $(which pip3) install platformio

RUN_VENDOR="any"
RUN_MODEL="any"
RUN_BOARD="any"
RUN_BRANCH="any"
RUN_FLAVOR="any"
RUN_DRY="no"

show_help() {
    printf "Usage: %s [-n] [-v VENDOR] [-m MODEL] [-b BOARD] [-r BRANCH] [-f FLAVOR]\n" "$(basename ${0})"
    printf "  -n\t\t\tDry run\n"
    printf "  -v VENDOR\t\tVendor name\n"
    printf "  -m MODEL\t\tModel name\n"
    printf "  -b BOARD\t\tBoard name\n"
    printf "  -r BRANCH\t\tBranch name\n"
    printf "  -f FLAVOR\t\tFlavor name\n"
    exit 0
}

show_usage() {
    printf "Usage: %s [-n] [-v VENDOR] [-m MODEL] [-b BOARD] [-r BRANCH] [-f FLAVOR]\n" "$(basename ${0})"
    exit 1
}

while getopts 'v:m:b:r:f:nh' opt; do
    case "${opt}" in
        v) RUN_VENDOR="${OPTARG}" ;;
        m) RUN_MODEL="${OPTARG}" ;;
        b) RUN_BOARD="${OPTARG}" ;;
        r) RUN_BRANCH="${OPTARG}" ;;
        f) RUN_FLAVOR="${OPTARG}" ;;
        n) RUN_DRY="yes" ;;
        h) show_help ;;
        *) show_usage ;;
    esac
done

test ! -d ${BUILD_DIR} && git clone ${MARLIN_REPO} ${BUILD_DIR}
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
                                        if test "${RUN_DRY}" = "no"; then
                                            mv -v ${build_obj} ${BASE}/${build_out}__$(basename ${build_obj})
                                        fi
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
