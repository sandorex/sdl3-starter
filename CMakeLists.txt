cmake_minimum_required(VERSION 3.21)

# set project version here so its useable in cmake script mode
set(PROJECT_VERSION 0.1.0)

# allow file to be called with `cmake -P CMakeLists.txt` to get full version
if(CMAKE_SCRIPT_MODE_FILE)
    include(${CMAKE_CURRENT_LIST_DIR}/cmake/ExtendedVersion.cmake)
    set(CMAKE_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR})
    extend_version(${PROJECT_VERSION} PROJECT_VERSION PROJECT_VERSION_LONG)
    message("${PROJECT_VERSION_LONG}")
    return()
endif()

# TODO add command for packaging with resources into a zip

project(SDL3Example VERSION "${PROJECT_VERSION}" LANGUAGES CXX)

include(cmake/Preludes.cmake)

# force static linking
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

# cache fetchcontent outside build
set(FETCHCONTENT_BASE_DIR ${CMAKE_SOURCE_DIR}/cmake_deps)

message(STATUS "Building config set to '${CMAKE_BUILD_TYPE}'")

# TODO try setting source path for each fetchcontent so all stuff can be in the proper binary path
if(ANDROID)
    message(STATUS "Building for Android")

    # prevent conflicts when building for android
    set(FETCHCONTENT_BASE_DIR "${FETCHCONTENT_BASE_DIR}_android")

    add_definitions(-DANDROID)
elif(EMSCRIPTEN)
    message(STATUS "Building for Web")

    # prevent conflicts when building for android
    set(FETCHCONTENT_BASE_DIR "${FETCHCONTENT_BASE_DIR}_web")

    # executables need to be html webpages for web
    set(CMAKE_EXECUTABLE_SUFFIX ".html" CACHE INTERNAL "")

    # TODO include resources for web
    
    add_definitions(-DWEB)
endif()

include(FetchContent)
include(cmake/FetchSDL.cmake)

if(ANDROID)
    # you have to compile it as a library named main on android
    set(executable_name main)
    add_library("${executable_name}" SHARED)
else()
    set(executable_name "${PROJECT_NAME}")
    add_executable("${executable_name}")
endif()

target_sources("${executable_name}" PRIVATE src/main.cc)

target_compile_features(${executable_name} PUBLIC cxx_std_20)

target_compile_definitions("${executable_name}" PUBLIC SDL_MAIN_USE_CALLBACKS=1)

# setup resource paths
if(ANDROID)
    # android loads from root so add nothing to the path
    target_compile_definitions("${executable_name}" PUBLIC RESOURCES_PATH="")
elseif(PRODUCTION)
    # for production load from current directory
    target_compile_definitions("${executable_name}" PUBLIC RESOURCES_PATH="./")
else()
    # make resource path relative
    set(resource_path "${CMAKE_CURRENT_SOURCE_DIR}/resources/")
    cmake_path(
        RELATIVE_PATH resource_path
        BASE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
    )

    # for debug excluding android just load directly from the resources directory
    target_compile_definitions("${executable_name}" PUBLIC RESOURCES_PATH="${resource_path}")
endif()

target_link_libraries("${executable_name}"
    PRIVATE
    SDL3::SDL3-static
    SDL3_ttf::SDL3_ttf-static
    SDL3_image::SDL3_image-static
)
