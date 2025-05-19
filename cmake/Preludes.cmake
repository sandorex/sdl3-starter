# create compile_commands.json for debugging and LSP
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "" FORCE)

# automatically add CMAKE_SOURCE_DIR and CMAKE_BINARY_DIR to include directories
set(CMAKE_INCLUDE_CURRENT_DIR ON CACHE BOOL "" FORCE)

# use sccache/ccache if available
find_program(SCCACHE sccache)
if(CCACHE)
    set(CMAKE_C_COMPILER_LAUNCHER "${SCCACHE}")
    set(CMAKE_CXX_COMPILER_LAUNCHER "${SCCACHE}")
    set(ccache_used ON)
else()
    find_program(CCACHE ccache)
    if(CCACHE)
        set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE}")
        set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE}")
        set(ccache_used ON)
    endif()
endif()

# use this when creating a release!
option(PRODUCTION "Compile production release" OFF)

# set a default build type if none was specified
set(default_build_type "RelWithDebInfo")
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Setting build type to '${default_build_type}' as none was specified.")
    set(CMAKE_BUILD_TYPE "${default_build_type}" CACHE STRING "Choose the type of build." FORCE)

    # set the possible values of build type for cmake-gui
    set(CMAKE_CONFIGURATION_TYPES "Debug;RelWithDebInfo" CACHE STRING "" FORCE) 
endif()

if(PRODUCTION_BUILD)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON CACHE BOOL "" FORCE)
else()
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF CACHE BOOL "" FORCE)
endif()

# statically link MS runtime
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Release>:Release>")

message(STATUS
    "Building configuration:\n"
    "  CMAKE_BUILD_TYPE: '${CMAKE_BUILD_TYPE}'\n"
    "  PRODUCTION: ${PRODUCTION}\n"
    "  SCCACHE / CCACHE: ${ccache_used}\n"
    "  PLATFORM: ${CMAKE_SYSTEM_NAME}"
)
