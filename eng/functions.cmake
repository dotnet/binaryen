function (get_symbol_file_name targetName outputSymbolFilename)
  if (CMAKE_SYSTEM_NAME STREQUAL Darwin)
    set(strip_destination_file $<TARGET_FILE:${targetName}>.dwarf)
    set(${outputSymbolFilename} ${strip_destination_file} PARENT_SCOPE)
  elseif (CMAKE_SYSTEM_NAME STREQUAL Linux)
    set(strip_destination_file $<TARGET_FILE:${targetName}>.dbg)
    set(${outputSymbolFilename} ${strip_destination_file} PARENT_SCOPE)
  else(CMAKE_SYSTEM_NAME STREQUAL Windows)
    # We can't use the $<TARGET_PDB_FILE> generator expression here since
    # the generator expression isn't supported on resource DLLs.
    set(${outputSymbolFilename} $<TARGET_FILE_DIR:${targetName}>/$<TARGET_FILE_PREFIX:${targetName}>$<TARGET_FILE_BASE_NAME:${targetName}>.pdb PARENT_SCOPE)
  endif()
endfunction()

function(strip_symbols targetName outputFilename)
  get_symbol_file_name(${targetName} strip_destination_file)
  set(${outputFilename} ${strip_destination_file} PARENT_SCOPE)
  if (NOT CMAKE_SYSTEM_NAME STREQUAL Windows)
    set(strip_source_file $<TARGET_FILE:${targetName}>)

    if (CMAKE_SYSTEM_NAME STREQUAL Darwin)

      # Ensure that dsymutil and strip are present
      find_program(DSYMUTIL dsymutil)
      if (DSYMUTIL STREQUAL "DSYMUTIL-NOTFOUND")
        message(FATAL_ERROR "dsymutil not found")
      endif()

      find_program(STRIP strip)
      if (STRIP STREQUAL "STRIP-NOTFOUND")
        message(FATAL_ERROR "strip not found")
      endif()

      set(strip_command ${STRIP} -no_code_signature_warning -S ${strip_source_file})

      # codesign release build
      string(TOLOWER "${CMAKE_BUILD_TYPE}" LOWERCASE_CMAKE_BUILD_TYPE)
      if (LOWERCASE_CMAKE_BUILD_TYPE STREQUAL release)
        set(strip_command ${strip_command} && codesign -f -s - ${strip_source_file})
      endif ()

      execute_process(
        COMMAND ${DSYMUTIL} --help
        OUTPUT_VARIABLE DSYMUTIL_HELP_OUTPUT
      )

      set(DSYMUTIL_OPTS "--flat")
      if ("${DSYMUTIL_HELP_OUTPUT}" MATCHES "--minimize")
        list(APPEND DSYMUTIL_OPTS "--minimize")
      endif ()

      add_custom_command(
        TARGET ${targetName}
        POST_BUILD
        VERBATIM
        COMMAND sh -c "echo Stripping symbols from $(basename '${strip_source_file}') into $(basename '${strip_destination_file}')"
        COMMAND ${DSYMUTIL} ${DSYMUTIL_OPTS} ${strip_source_file}
        COMMAND ${strip_command}
        )
    else ()

      add_custom_command(
        TARGET ${targetName}
        POST_BUILD
        VERBATIM
        COMMAND sh -c "echo Stripping symbols from $(basename '${strip_source_file}') into $(basename '${strip_destination_file}')"
        COMMAND ${CMAKE_OBJCOPY} --only-keep-debug ${strip_source_file} ${strip_destination_file}
        COMMAND ${CMAKE_OBJCOPY} --strip-debug --strip-unneeded ${strip_source_file}
        COMMAND ${CMAKE_OBJCOPY} --add-gnu-debuglink=${strip_destination_file} ${strip_source_file}
        )
    endif ()
  endif()
endfunction()

function(install_with_stripped_symbols targetName kind destination)
  get_property(target_is_framework TARGET ${targetName} PROPERTY "FRAMEWORK")
  strip_symbols(${targetName} symbol_file)
  if (NOT "${symbol_file}" STREQUAL "" AND NOT target_is_framework)
    install(FILES ${symbol_file} DESTINATION ${destination} ${ARGN})
  endif()

  if (target_is_framework)
    install(TARGETS ${targetName} FRAMEWORK DESTINATION ${destination} ${ARGN})
  else()
    if (CMAKE_SYSTEM_NAME STREQUAL Darwin AND ("${kind}" STREQUAL "TARGETS"))
      # We want to avoid the kind=TARGET install behaviors which corrupt code signatures on osx-arm64
      set(kind PROGRAMS)
    endif()

    if ("${kind}" STREQUAL "TARGETS")
      set(install_source ${targetName})
    elseif("${kind}" STREQUAL "PROGRAMS")
      set(install_source $<TARGET_FILE:${targetName}>)
    else()
      message(FATAL_ERROR "The `kind` argument has to be either TARGETS or PROGRAMS, ${kind} was provided instead")
    endif()
    install(${kind} ${install_source} DESTINATION ${destination} ${ARGN})
  endif()
endfunction()

