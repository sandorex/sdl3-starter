if(ANDROID)
    # for android it has to be built as a shared library named "main"
    set(executable_name main)
    add_library("${executable_name}" SHARED)
else()
    set(executable_name "${PROJECT_NAME}")
    add_executable("${executable_name}")

    if(EMSCRIPTEN)
        # package all resources and make them available at the root
        target_link_libraries("${executable_name}"
            PRIVATE
            "--preload-file \"${resource_dir}@\""
        )
    endif()
endif()

target_fix_ld("${executable_name}")

target_sources("${executable_name}"
    PRIVATE
    main.cc
)

target_link_libraries("${executable_name}"
    PRIVATE
    project_options
    project_warnings
    
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
    endif()
endif()
