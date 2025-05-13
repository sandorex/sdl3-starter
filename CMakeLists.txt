cmake_minimum_required(VERSION 3.21)
project(MySDLApp)

include(cmake/Preludes.cmake)

set(CMAKE_CXX_STANDARD 20)

# force static linking
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

# cache fetchcontent outside build
set(FETCHCONTENT_BASE_DIR ${CMAKE_SOURCE_DIR}/cmake_deps)

message(STATUS "Building config set to '${CMAKE_BUILD_TYPE}'")

if(ANDROID)
    message(STATUS "Building for Android")

    # prevent conflicts when building for android
    set(FETCHCONTENT_BASE_DIR "${FETCHCONTENT_BASE_DIR}_android")
    
    add_definitions(-DANDROID)
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

set_property(TARGET "${executable_name}" PROPERTY CXX_STANDARD 20)

if(PRODUCTION)
  	target_compile_definitions("${executable_name}" PUBLIC RESOURCES_PATH="./resources/")
else()
  	target_compile_definitions("${executable_name}" PUBLIC RESOURCES_PATH="${CMAKE_CURRENT_SOURCE_DIR}/resources/")
endif()

target_link_libraries("${executable_name}"
    SDL3::SDL3-static
    SDL3_ttf::SDL3_ttf-static
    SDL3_image::SDL3_image-static
)
