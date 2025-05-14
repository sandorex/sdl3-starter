package io.github.sandorex.sdl3example;

import org.libsdl.app.SDLActivity;

public class MainActivity extends SDLActivity {
    @Override
    protected String[] getLibraries() {
        return new String[] {
            // NOTE: all libraries are statically linked!
            "main"
        };
    }
}
