// callbacks are easier to do cross-platform-ly
#define SDL_MAIN_USE_CALLBACKS

#include "SDL3/SDL_error.h"
#include "SDL3/SDL_filesystem.h"
#include "SDL3/SDL_init.h"
#include "SDL3/SDL_log.h"
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#include <SDL3_image/SDL_image.h>
#include <filesystem>

static SDL_Window *window = NULL;
static SDL_Renderer *renderer = NULL;
static SDL_Texture *texture = NULL;

SDL_AppResult SDL_AppInit(void **appstate, int argc, char *argv[]) {
#if !defined(WEB) && !defined(ANDROID)
    auto base_path = SDL_GetBasePath();
    if (!base_path) {
        SDL_Log("Could not get application base path: %s\n", SDL_GetError());
        return SDL_APP_FAILURE;
    }

    // change directory into executable directory
    std::filesystem::current_path(base_path);
#endif

    /* Create the window */
    if (!SDL_CreateWindowAndRenderer("SDL3 Example", 800, 600, SDL_WINDOW_FULLSCREEN, &window, &renderer)) {
        SDL_Log("Couldn't create window and renderer: %s\n", SDL_GetError());
        return SDL_APP_FAILURE;
    }

    // load sword image
    // NOTE RESOURCES_PATH is required as debug builds do not copy resources
    texture = IMG_LoadTexture(renderer, RESOURCES_PATH "sword.jpg");
    if (!texture) {
        SDL_Log("Couldn't load sword image: %s\n", SDL_GetError());
        return SDL_APP_FAILURE;
    }

    return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppEvent(void *appstate, SDL_Event *event) {
    if (event->type == SDL_EVENT_KEY_DOWN ||
        event->type == SDL_EVENT_QUIT) {
        return SDL_APP_SUCCESS;  /* end the program, reporting success to the OS. */
    }
    return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppIterate(void *appstate) {
    int w = 0, h = 0;
    SDL_FRect dst;
    const float scale = 4.0f;

    /* Center the icon and scale it up */
    SDL_GetRenderOutputSize(renderer, &w, &h);
    SDL_SetRenderScale(renderer, scale, scale);
    SDL_GetTextureSize(texture, &dst.w, &dst.h);
    dst.x = ((w / scale) - dst.w) / 2;
    dst.y = ((h / scale) - dst.h) / 2;

    /* Draw the icon */
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    SDL_RenderClear(renderer);
    SDL_RenderTexture(renderer, texture, NULL, &dst);
    SDL_RenderPresent(renderer);

    return SDL_APP_CONTINUE;
}

void SDL_AppQuit(void *appstate, SDL_AppResult result) {}
