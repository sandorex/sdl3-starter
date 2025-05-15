cmake_minimum_required(VERSION 3.21)

# set project version here so its useable in cmake script mode
set(PROJECT_VERSION 0.1.0)

include(cmake/ExtendedVersion.cmake)

# allow file to be called with `cmake -P CMakeLists.txt` to get full version
if(CMAKE_SCRIPT_MODE_FILE)
    set(CMAKE_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR})
    extend_version(${PROJECT_VERSION} PROJECT_VERSION PROJECT_VERSION_LONG)
    message("${PROJECT_VERSION_LONG}")
    return()
endif()

# get full version with git commit
extend_version(${PROJECT_VERSION} PROJECT_VERSION PROJECT_VERSION_LONG)

project(SDL3Example VERSION "${PROJECT_VERSION}" LANGUAGES CXX)

include(cmake/Preludes.cmake)

# force static linking
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

message(STATUS "Building config set to '${CMAKE_BUILD_TYPE}', production: ${PRODUCTION}")

if(ANDROID)
    message(STATUS "Building for Android")

    # for android it has to be built as a shared library named "main"
    set(executable_name main)
    add_library("${executable_name}" SHARED)
    target_compile_definitions("${executable_name}" PUBLIC ANDROID)
else()
    set(executable_name "${PROJECT_NAME}")
    add_executable("${executable_name}")
endif()

if(EMSCRIPTEN)
    message(STATUS "Building for Web")

    # required to build actual webpages
    set_target_properties("${executable_name}" PROPERTIES SUFFIX ".html")
    target_compile_definitions("${executable_name}" PUBLIC WEB)

    # take all resources from resources/ directory
    target_link_libraries("${executable_name}" PRIVATE
        "--preload-file \"${CMAKE_SOURCE_DIR}/resources\""
    )
endif()

target_sources("${executable_name}" PRIVATE src/main.cc)
target_compile_features(${executable_name} PUBLIC cxx_std_20)

target_compile_definitions("${executable_name}"
    PUBLIC
    VERSION="${PROJECT_VERSION}"
    VERSION_LONG="${PROJECT_VERSION_LONG}"

    SDL_MAIN_USE_CALLBACKS=1
)

# setup resource paths
if(ANDROID)
    # android loads from root so add nothing to the path
    target_compile_definitions("${executable_name}" PUBLIC RESOURCES_PATH="")
elseif(EMSCRIPTEN)
    # TODO idk what to set
    target_compile_definitions("${executable_name}" PUBLIC RESOURCES_PATH="resources/")
elseif(PRODUCTION)
    # for production load from current directory
    target_compile_definitions("${executable_name}" PUBLIC RESOURCES_PATH="./")
else()
    # make resource path relative for debug builds
    set(resource_path "${CMAKE_CURRENT_SOURCE_DIR}/resources/")
    cmake_path(
        RELATIVE_PATH resource_path
        BASE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
    )

    target_compile_definitions("${executable_name}" PUBLIC RESOURCES_PATH="${resource_path}")
endif()

include(cmake/FetchDependencies.cmake)

target_link_libraries("${executable_name}"
    PRIVATE
    SDL3::SDL3-static
    SDL3_ttf::SDL3_ttf-static
    SDL3_image::SDL3_image-static
)

# package application as a zip
install(
    DIRECTORY "${CMAKE_SOURCE_DIR}/resources"
    DESTINATION .
)
install(
    TARGETS "${executable_name}"
    RUNTIME DESTINATION .
)

set(CPACK_GENERATOR "ZIP" CACHE STRING "" FORCE)
set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF)
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION_LONG}")
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}")

include(CPack)
