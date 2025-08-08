add_custom_command(
  OUTPUT word.dat
  COMMAND ${CHEWING_CLI} init --csv ${CMAKE_CURRENT_SOURCE_DIR}/word.csv word.dat 
  DEPENDS word.csv
)
add_custom_command(
  OUTPUT tsi.dat
  COMMAND ${CHEWING_CLI} init --csv ${CMAKE_CURRENT_SOURCE_DIR}/tsi.csv tsi.dat 
  DEPENDS tsi.csv
)
add_custom_command(
  OUTPUT mini.dat
  COMMAND ${CHEWING_CLI} init --csv ${CMAKE_CURRENT_SOURCE_DIR}/mini.csv mini.dat 
  DEPENDS mini.csv
)
add_custom_target(dict_chewing ALL DEPENDS word.dat tsi.dat mini.dat)

