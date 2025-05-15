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

# path where all assets are
set(resource_dir "${CMAKE_SOURCE_DIR}/resources")

include(cmake/Preludes.cmake)

message(STATUS "Building config set to '${CMAKE_BUILD_TYPE}', production: ${PRODUCTION}")

if(ANDROID)
    message(STATUS "Building for Android")

    # for android it has to be built as a shared library named "main"
    set(executable_name main)
    add_library("${executable_name}" SHARED)
    target_compile_definitions("${executable_name}" PRIVATE ANDROID)
else()
    set(executable_name "${PROJECT_NAME}")
    add_executable("${executable_name}")
endif()

if(EMSCRIPTEN)
    message(STATUS "Building for Web")

    # required to build actual webpages
    set_target_properties("${executable_name}" PROPERTIES SUFFIX ".html")
    target_compile_definitions("${executable_name}" PRIVATE WEB)

    # package all resources and make them available as the root
    target_link_libraries("${executable_name}"
        PRIVATE
        "--preload-file \"${resource_dir}@\""
    )
endif()

target_sources("${executable_name}" PRIVATE src/main.cc)

target_compile_definitions("${executable_name}"
    PRIVATE
    VERSION="${PROJECT_VERSION}"
    VERSION_LONG="${PROJECT_VERSION_LONG}"

    SDL_MAIN_USE_CALLBACKS=1
)

# get relative path to assets for debug builds / tests
cmake_path(
    RELATIVE_PATH resource_dir
    BASE_DIRECTORY "${CMAKE_BINARY_DIR}"
    OUTPUT_VARIABLE resource_dir_relative
)

# setup resource paths
if(ANDROID OR EMSCRIPTEN OR PRODUCTION)
    # load from root so use empty path
    target_compile_definitions("${executable_name}" PRIVATE RESOURCES_PATH="")
else()
    # on desktop use relative path so debug builds can access resources without copying
    target_compile_definitions("${executable_name}" PRIVATE RESOURCES_PATH="${resource_dir_relative}/")
endif()

include(cmake/FetchDependencies.cmake)

# link app libraries here
target_link_libraries("${executable_name}"
    PRIVATE
    SDL3::SDL3-static
    SDL3_ttf::SDL3_ttf-static
    SDL3_image::SDL3_image-static
)

# enable tests only if not crosscompiling (web, android, mingw)
if(NOT CMAKE_CROSSCOMPILING)
    add_executable(tests src/main_tests.cc)

    # allow access to resources in tests just in case
    target_compile_definitions(tests
        PRIVATE
        RESOURCES_PATH="${resource_dir_relative}"
    )

    # link additional test libraries here
    target_link_libraries(tests
        PRIVATE
        doctest
    )

    enable_testing()
    include(${doctest_SOURCE_DIR}/scripts/cmake/doctest.cmake)
    doctest_discover_tests(tests)
endif()

# package application as zip (except android where gradle does everything)
if(NOT ANDROID)
    if(EMSCRIPTEN)
        # for emscripten you have to manually copy all the files
        install(
            FILES
            "$<TARGET_FILE_DIR:${executable_name}>/${executable_name}.html"
            "$<TARGET_FILE_DIR:${executable_name}>/${executable_name}.wasm"
            "$<TARGET_FILE_DIR:${executable_name}>/${executable_name}.js"
            "$<TARGET_FILE_DIR:${executable_name}>/${executable_name}.data"
            DESTINATION .
        )
    else()
        # package resources with the applications
        install(
            # NOTE: the slash is important as we want only the files installed
            # not the directory itself!
            DIRECTORY "${resource_dir}/"
            DESTINATION .
        )

        # copy the executable
        install(
            TARGETS "${executable_name}"
            RUNTIME DESTINATION .
        )
    endif()

    set(CPACK_GENERATOR "ZIP" CACHE STRING "" FORCE)
    set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF)
    set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
    set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION_LONG}")
    set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}")

    include(CPack)
endif()
