set(TARGETS word.dat tsi.dat alt.dat mini.dat)
add_custom_target(dict_chewing ALL DEPENDS ${TARGETS})

foreach(TARGET ${TARGETS})
  string(REPLACE "dat" "csv" SRC ${TARGET})
  add_custom_command(
    OUTPUT ${TARGET}
    COMMAND ${CHEWING_CLI} init --csv ${CMAKE_CURRENT_SOURCE_DIR}/${SRC} ${TARGET}
    DEPENDS ${SRC}
  )
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${TARGET} DESTINATION ${CMAKE_INSTALL_DATADIR}/libchewing)
endforeach()
