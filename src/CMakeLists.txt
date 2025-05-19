if(ANDROID)
    # for android it has to be built as a shared library named "main"
    set(executable_name main)
    add_library("${executable_name}" SHARED)
else()
    set(executable_name "${PROJECT_NAME}")
    add_executable("${executable_name}")

    if(EMSCRIPTEN)
        # package all resources and make them available as the root
        target_link_libraries("${executable_name}"
            PRIVATE
            "--preload-file \"${resource_dir}@\""
        )
    endif()
endif()

target_sources("${executable_name}"
    PRIVATE
    main.cc
)

target_link_libraries("${executable_name}"
    PRIVATE
    project_options
    project_warnings
    project_defines
    
    SDL3::SDL3-static
    SDL3_ttf::SDL3_ttf-static
    SDL3_image::SDL3_image-static
)

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

        # fix interpreter path if not building for nix
        if(NOT DEFINED NIX_BUILD)
            # TODO run patchelf
            message(STATUS "Fixing interpreter path of executable ${executable_name} (TODO)")
        endif()

        # TODO fix interpreter path when built in nix
        # # restore ld for binary when built in nix shell
        # if(DEFINED ENV{IN_NIX_SHELL})
        #     # install(CODE "message(\"Hello $<TARGET_FILE:${executable_name}>\")")
        # install(CODE "execute_process(COMMAND patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 $<TARGET_FILE:${executable_name}>)")
        # endif()
    endif()
endif()
