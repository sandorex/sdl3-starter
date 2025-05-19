cmake_minimum_required(VERSION 3.21)

# set project version here so its useable in cmake script mode
set(PROJECT_VERSION 0.1.0)

include(cmake/ExtendedVersion.cmake)

# if called as a script (`cmake -P CMakeLists.txt`) just print the version and quit
if(CMAKE_SCRIPT_MODE_FILE)
    # CMAKE_SOURCE_DIR is not defined in script mode
    report_version("${PROJECT_VERSION}" "${CMAKE_CURRENT_LIST_DIR}")
    return()
endif()

# get long version with git commit
extend_version(${PROJECT_VERSION} PROJECT_VERSION PROJECT_VERSION_LONG)
project(SDL3Example VERSION "${PROJECT_VERSION}" LANGUAGES CXX)

# path where all assets are
set(resource_dir "${CMAKE_SOURCE_DIR}/resources")

include(cmake/Preludes.cmake)

# interface libraries to share project options, warnings, defines
add_library(project_warnings INTERFACE)
if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    # make 
    target_compile_options(project_warnings
        INTERFACE
        # treat undefined macros as errors
        -Werror=undef

        # more warnings
        -Wall
        -pedantic

        # treat warnings as errors
        -Werror
    )
elseif(MSVC)
    # warning level 4 and all warnings as errors
    target_compile_options(project_warnings
        INTERFACE
        # more warning
        /W4

        # treat warnings as errors
        /WX
    )
endif()

add_library(project_options INTERFACE)

# require C++20
target_compile_features(project_options INTERFACE cxx_std_20)

add_library(project_defines INTERFACE)

if(EMSCRIPTEN)
    # required to actually make a webpage instead you get javascript and wasm only
    set_target_properties(project_options PROPERTIES SUFFIX ".html")
endif()

# if(ANDROID)
#     message(STATUS "Building for Android")
#     target_compile_definitions(project_defines INTERFACE ANDROID)
# elseif(EMSCRIPTEN)
#     message(STATUS "Building for Web")
#     target_compile_definitions(project_defines INTERFACE WEB)

#     # required to actually make a webpage instead you get wasm
#     set_target_properties(project_defines PROPERTIES SUFFIX ".html")
# else()
#     message(STATUS "Building for Desktop")
#     target_compile_definitions(project_defines INTERFACE DESKTOP)
# endif()

# target_compile_definitions(project_defines
#     INTERFACE
#     VERSION="${PROJECT_VERSION}"
#     VERSION_LONG="${PROJECT_VERSION_LONG}"
# )

# # setup resource paths
# if(ANDROID OR EMSCRIPTEN OR PRODUCTION)
#     # load from root so use empty path
#     set(resources_path "")
#     # target_compile_definitions(project_defines INTERFACE RESOURCES_PATH="")
# else()
# get relative path to assets for debug builds / tests
cmake_path(
    RELATIVE_PATH resource_dir
    BASE_DIRECTORY "${CMAKE_BINARY_DIR}"
    OUTPUT_VARIABLE resource_path
)

#     # set(resource_path)
#     # on desktop use relative path so debug builds can access resources without copying
#     target_compile_definitions(project_defines INTERFACE RESOURCES_PATH="${resource_dir_relative}/")
# endif()
configure_file(src/options.h.in options.h)


include(cmake/FetchDependencies.cmake)

# enable tests only if not crosscompiling (web, android, mingw)
if(NOT CMAKE_CROSSCOMPILING)
    add_subdirectory(tests)
endif()

## PACKAGING ##
if(NOT ANDROID)
    # package project as a zip file with everything in root of it
    set(CPACK_GENERATOR "ZIP" CACHE STRING "" FORCE)
    set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF)
    set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
    set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION_LONG}")
    set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}")

    include(CPack)
endif()
