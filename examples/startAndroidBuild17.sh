#!/bin/bash

# LineageBuilder

export PROJECT_PATH=/development/lenovo/android17_dev

if [ -z "$BUILD_WITH_GAPPS" ]; then
    echo "Building with GAPPS"
    BUILD_WITH_GAPPS=false
#else
#    echo "Building with GAPPS = $BUILD_WITH_GAPPS"
fi
echo "Building with GAPPS = $BUILD_WITH_GAPPS"

docker run \
    -t -i \
    --rm \
    --memory=14G \
    --memory-swap=14G \
    --name "LineageOSBuilder17" \
    -e "BUILD_WITH_GAPPS=$BUILD_WITH_GAPPS" \
    -e "BUILD_HOSTNAME=LineageOSBuilder" \
    -e "USE_CCACHE=1" \
    -e "CCACHE_COMPRESS=true" \
    -e "USE_CCACHE=true" \
    -e "CCACHE_EXEC=/usr/sbin/ccache" \
    -e "DEBUG=true" \
    -e "USER_NAME=John Doe" \
    -e "USER_MAIL=john.doe@awesome.email" \
    -e "BRANCH_NAME=lineage17" \
    -e "DEVICE_LIST=" \
    -e "OTA_URL=http://cool.domain/api" \
    -e "JAVA_TOOL_OPTIONS=-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap" \
    -e "TEMPORARY_DISABLE_PATH_RESTRICTIONS=true" \
    -e "MAX_JAVA_PROCESSES=2" \
    --privileged \
    -v /dev/bus/usb:/dev/bus/usb \
    -v /home/mueller/.android:/root/.android \
    -v "$PROJECT_PATH/ccache:/srv/ccache" \
    -v "$PROJECT_PATH/android:/srv/src" \
    -v "$PROJECT_PATH/out:/srv/src/out" \
    -v "$PROJECT_PATH/zips:/srv/zips" \
    -v "/development/lenovo/local_manifests:/srv/local_manifests" \
    private/docker-lineage-cicd "$@"

ID=`docker ps --no-trunc -q --filter "name=LineageOSBuilder17"`
echo $ID
cgset --copy-from "" "docker/$ID"
