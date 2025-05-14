include(FetchContent)

# NOTE: make sure to use android/ files from this specific version of SDL!
FetchContent_Declare(
    SDL3
    GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
    GIT_TAG release-3.2.10
)
set(SDL3_DISABLE_SHARED TRUE CACHE BOOL "" FORCE)
set(SDL3_DISABLE_SDL2_COMPAT TRUE CACHE BOOL "" FORCE)
set(SDL_TEST_LIBRARY FALSE CACHE BOOL "" FORCE)
set(SDL3_INSTALL FALSE CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(SDL3)

FetchContent_Declare(
    SDL3_ttf
    GIT_REPOSITORY https://github.com/libsdl-org/SDL_ttf.git
    GIT_TAG release-3.2.2
)
set(SDL3TTF_DISABLE_SHARED TRUE CACHE BOOL "" FORCE)
set(SDL3TTF_INSTALL FALSE CACHE BOOL "" FORCE)
set(SDL3TTF_VENDORED TRUE CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(SDL3_ttf)

FetchContent_Declare(
    SDL3_image
    GIT_REPOSITORY https://github.com/libsdl-org/SDL_image.git
    GIT_TAG release-3.2.4
)
set(SDL3IMAGE_DISABLE_SHARED TRUE CACHE BOOL "" FORCE)
set(SDL3IMAGE_INSTALL FALSE CACHE BOOL "" FORCE)
set(SDL3IMAGE_VENDORED TRUE CACHE BOOL "" FORCE)
set(SDL3IMAGE_BACKEND_DEFAULT "stb" CACHE STRING "" FORCE)
FetchContent_MakeAvailable(SDL3_image)
