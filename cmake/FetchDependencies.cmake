# all dependencies should be defined here
#
# SOURCE_DIR is set so dependencies can be shared between builds (release, debug, android, web.. etc)
# 
# SUBBUILD_DIR is where cmake keeps information about a specific content,
#   without this option cmake will redownload everything each time build dir
#   changes

include(FetchContent)

# force static linking
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

# where dependencies will
set(DEPS_DIR "${CMAKE_SOURCE_DIR}/deps")

# NOTE: when changing SDL version make sure to update JNI files in android/
# to the ones from the new version
FetchContent_Declare(
    SDL3
    GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
    GIT_TAG release-3.2.10
    GIT_SHALLOW TRUE
    SOURCE_DIR "${DEPS_DIR}/SDL3"
    SUBBUILD_DIR "${DEPS_DIR}/SDL3-subbuild"
)
set(SDL_DISABLE_SHARED TRUE CACHE BOOL "" FORCE)
set(SDL_TEST_LIBRARY FALSE CACHE BOOL "" FORCE)
set(SDL_INSTALL FALSE CACHE BOOL "" FORCE)

FetchContent_Declare(
    SDL3_ttf
    GIT_REPOSITORY https://github.com/libsdl-org/SDL_ttf.git
    GIT_TAG release-3.2.2
    GIT_SHALLOW TRUE
    SOURCE_DIR "${DEPS_DIR}/SDL3_ttf"
    SUBBUILD_DIR "${DEPS_DIR}/SDL3_ttf-subbuild"
)
set(SDLTTF_DISABLE_SHARED TRUE CACHE BOOL "" FORCE)
set(SDLTTF_INSTALL FALSE CACHE BOOL "" FORCE)
set(SDLTTF_VENDORED TRUE CACHE BOOL "" FORCE)

FetchContent_Declare(
    SDL3_image
    GIT_REPOSITORY https://github.com/libsdl-org/SDL_image.git
    GIT_TAG release-3.2.4
    GIT_SHALLOW TRUE
    SOURCE_DIR "${DEPS_DIR}/SDL3_image"
    SUBBUILD_DIR "${DEPS_DIR}/SDL3_image-subbuild"
)
set(SDLIMAGE_DISABLE_SHARED TRUE CACHE BOOL "" FORCE)
set(SDLIMAGE_INSTALL FALSE CACHE BOOL "" FORCE)
set(SDLIMAGE_VENDORED TRUE CACHE BOOL "" FORCE)

# explicitly enable common formats
set(SDLIMAGE_GIF TRUE CACHE BOOL "" FORCE)
set(SDLIMAGE_JPG TRUE CACHE BOOL "" FORCE)
set(SDLIMAGE_PNG TRUE CACHE BOOL "" FORCE)
set(SDLIMAGE_SVG TRUE CACHE BOOL "" FORCE)

# disable less common formats
set(SDLIMAGE_WEBP FALSE CACHE BOOL "" FORCE)
set(SDLIMAGE_BMP FALSE CACHE BOOL "" FORCE)
set(SDLIMAGE_AVIF FALSE CACHE BOOL "" FORCE)
set(SDLIMAGE_JXL FALSE CACHE BOOL "" FORCE)
set(SDLIMAGE_LBM FALSE CACHE BOOL "" FORCE)
set(SDLIMAGE_PCX FALSE CACHE BOOL "" FORCE)
set(SDLIMAGE_PNM FALSE CACHE BOOL "" FORCE)
set(SDLIMAGE_QOI FALSE CACHE BOOL "" FORCE)
set(SDLIMAGE_TGA FALSE CACHE BOOL "" FORCE)
set(SDLIMAGE_TIF FALSE CACHE BOOL "" FORCE)
set(SDLIMAGE_XCF FALSE CACHE BOOL "" FORCE)
set(SDLIMAGE_XPM FALSE CACHE BOOL "" FORCE)
set(SDLIMAGE_XV FALSE CACHE BOOL "" FORCE)

FetchContent_Declare(
    doctest
    GIT_REPOSITORY https://github.com/doctest/doctest.git
    GIT_TAG v2.4.12
    GIT_SHALLOW TRUE
    SOURCE_DIR "${DEPS_DIR}/doctest"
    SUBBUILD_DIR "${DEPS_DIR}/doctest-subbuild"
)
# disable installation of doctest files
set(DOCTEST_NO_INSTALL TRUE CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(
    SDL3
    SDL3_ttf
    SDL3_image
    doctest
)
