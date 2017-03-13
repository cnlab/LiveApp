#!/bin/bash

success=true

function pass {
    echo "[$(tput setaf 2)pass$(tput sgr0)] $*"
}

function fail {
    echo "[$(tput setab 1)$(tput setaf 7)FAIL$(tput sgr0)] $*"
    success=false
}

function check {
    if [ $1 -eq 0 ]
    then
        pass "$2"
    else
        fail "$2"
    fi
}

function tag_for {
    local name=$1
    local dir=$1

    plist="${dir}/${name}/Info.plist"
    if [ ! -f "${plist}" ]; then
        plist="${dir}/${name}/${name}-Info.plist"
    fi
    versionMajorMinor=`/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${plist}"`
    versionRelease=`/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "${plist}"`
    version="${versionMajorMinor}.${versionRelease}"
    tag="${name}-v${version}"
    echo "${tag}"
}

function build_app {
    local name=$1
    local platform=$2

    echo "building ${platform} app ${name}..."
    pushd "${name}" >/dev/null
    xcodebuild -configuration Release -scheme "${name}" clean archive -archivePath "${build}/${name}.xcarchive" >>"${log}" 2>&1
    check $? "build ${platform} app ${name}"
    popd >/dev/null
    if [ "$success" = true ]
    then
        rm -rf "${build}/${platform}/app/${name}.app"
        mkdir -p "${build}/${platform}/app"
        mv "${build}/${name}.xcarchive/Products/Applications/${name}.app" "${build}/${platform}/app/"
        rm -rf "${build}/${name}.xcarchive"

        tag=$(tag_for "${name}")
        echo "creating release/${tag}.zip"
        rm -rf "release/${tag}.zip"
        pushd "${build}/${platform}/app" >/dev/null
        zip -rq "../../../release/${tag}.zip" "${name}.app"
        popd >/dev/null
    fi
}

root=`pwd`
build="${root}/build"
log="${build}/build.log"

mkdir -p "${build}"
rm -f "${log}"
mkdir -p "release"

build_app Live iOS
build_app "Live Cloud" macOS

if [ "$success" = true ]
then
    exit 0
else
    exit 1
fi
