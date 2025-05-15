DEBUG_CONFIG := 'Debug'
RELEASE_CONFIG := 'RelWithDebInfo'

_default:
    @just --list

_web build_dir config +ARGS:
    #!/usr/bin/env bash
    dir_name='{{ justfile_directory() }}/{{ build_dir }}'
    [[ -d "$dir_name" ]] || emcmake cmake -B "$dir_name" -DCMAKE_BUILD_TYPE='{{ config }}' {{ ARGS }}
    cmake --build "$dir_name"

# build for web debug
web-debug *ARGS: (_web 'web_debug' DEBUG_CONFIG ARGS)

# build for web release
web-release *ARGS: (_web 'web_release' RELEASE_CONFIG ARGS)

_linux build_dir config +ARGS:
    #!/usr/bin/env bash
    dir_name='{{ justfile_directory() }}/{{ build_dir }}'
    [[ -d "$dir_name" ]] || cmake -B "$dir_name" -DCMAKE_BUILD_TYPE='{{ config }}' {{ ARGS }}
    cmake --build "$dir_name"

# build for linux debug
linux-debug *ARGS: (_linux 'linux_debug' DEBUG_CONFIG ARGS)

# build for linux release
linux-release *ARGS: (_linux 'linux_release' RELEASE_CONFIG ARGS)
