# create compile_commands.json for debugging and LSP
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "" FORCE)

# output all executables and libraries in /bin
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

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

# # option to fix dynamic linker path when building with nix
# # NOTE: this may break things
# if(CMAKE_FORCE_LD AND UNIX)
#     add_link_options("LINK:--dynamic-linker ${CMAKE_FORCE_LD}")
# endif()

macro(target_fix_ld target)
    if(UNIX AND CMAKE_FORCE_LD)
        # create a step where the dynamic linker is set to requested value
        add_custom_command(
            TARGET "${target}" POST_BUILD
            COMMAND patchelf --set-interpreter ${CMAKE_FORCE_LD} $<TARGET_FILE:${target}>
            # WORKING_DIRECTORY "$<TARGET_FILE_DIR:${target}>"
            COMMENT "Fixing dynamic linker for '${target}'"
        )
    endif()
endmacro()

# options summary
message(STATUS
    "Build configuration:\n"
    "  CMAKE_BUILD_TYPE: '${CMAKE_BUILD_TYPE}'\n"
    "  PRODUCTION: ${PRODUCTION}\n"
    "  SCCACHE / CCACHE: ${ccache_used}\n"
    "  PLATFORM: ${CMAKE_SYSTEM_NAME}\n"
    "  CMAKE_FORCE_LD: ${CMAKE_FORCE_LD}"
)
