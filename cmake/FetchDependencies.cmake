include(FetchContent)

# NOTE: make sure to use android/ files from this specific version of SDL!
FetchContent_Declare(
    SDL3
    GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
    GIT_TAG release-3.2.10
)
set(SDL_DISABLE_SHARED TRUE CACHE BOOL "" FORCE)
set(SDL_TEST_LIBRARY FALSE CACHE BOOL "" FORCE)
set(SDL_INSTALL FALSE CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(SDL3)

FetchContent_Declare(
    SDL3_ttf
    GIT_REPOSITORY https://github.com/libsdl-org/SDL_ttf.git
    GIT_TAG release-3.2.2
)
set(SDLTTF_DISABLE_SHARED TRUE CACHE BOOL "" FORCE)
set(SDLTTF_INSTALL FALSE CACHE BOOL "" FORCE)
set(SDLTTF_VENDORED TRUE CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(SDL3_ttf)

FetchContent_Declare(
    SDL3_image
    GIT_REPOSITORY https://github.com/libsdl-org/SDL_image.git
    GIT_TAG release-3.2.4
)
set(SDLIMAGE_DISABLE_SHARED TRUE CACHE BOOL "" FORCE)
set(SDLIMAGE_INSTALL FALSE CACHE BOOL "" FORCE)
set(SDLIMAGE_VENDORED TRUE CACHE BOOL "" FORCE)
set(SDLIMAGE_BACKEND_DEFAULT "stb" CACHE STRING "" FORCE)

# TODO remove all uncommon formats
# unecessary
set(SDLIMAGE_AVIF FALSE CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(SDL3_image)
