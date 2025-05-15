RELEASE_CONFIG := 'RelWithDebInfo'

WEB_BUILD_DIR := justfile_directory() + '/build_web'
LINUX_BUILD_DIR := justfile_directory() + '/build'
# MINGW_BUILD_DIR := justfile_directory() + '/build_mingw32'

_default:
    @just --list

# build and package for android
android:
    #!/usr/bin/env bash
    set -euo pipefail

    cd android

    ./gradlew assembleRelease

# build and package with emscripten
web:
    #!/usr/bin/env bash
    set -euo pipefail

    # configure using emscripten
    emcmake cmake -B '{{ WEB_BUILD_DIR }}' -DPRODUCTION=1 -DCMAKE_BUILD_TYPE='{{ RELEASE_CONFIG }}'

    # package the webapp
    cmake --build '{{ WEB_BUILD_DIR }}' --target package

# build and package for linux
linux:
    #!/usr/bin/env bash
    set -euo pipefail

    # configure using emscripten
    cmake -B '{{ LINUX_BUILD_DIR }}' -DPRODUCTION=1 -DCMAKE_BUILD_TYPE='{{ RELEASE_CONFIG }}'

    # package the webapp
    cmake --build '{{ LINUX_BUILD_DIR }}' --target package
