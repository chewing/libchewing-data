add_custom_command(
  OUTPUT swkb.dat
  COMMAND ${CMAKE_COMMAND} -E copy
    ${CMAKE_CURRENT_SOURCE_DIR}/swkb.dat
    ${CMAKE_CURRENT_BINARY_DIR}/swkb.dat
  DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/swkb.dat
)
add_custom_command(
  OUTPUT symbols.dat
  COMMAND ${CMAKE_COMMAND} -E copy
    ${CMAKE_CURRENT_SOURCE_DIR}/symbols.dat
    ${CMAKE_CURRENT_BINARY_DIR}/symbols.dat
  DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/symbols.dat
)
add_custom_target(misc ALL DEPENDS swkb.dat symbols.dat)
