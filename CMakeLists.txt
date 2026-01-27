cmake_minimum_required(VERSION 3.31.6...3.31.6)
project(libchewing-data VERSION 2026.1.27 LANGUAGES NONE)

if(PROJECT_IS_TOP_LEVEL)
  set(CMAKE_SYSTEM_NAME Generic)
endif()

option(USE_SYSTEM_CHEWING_CLI "Use system-installed chewing-cli instead of building from source" ON)

if(USE_SYSTEM_CHEWING_CLI)
  find_program(CHEWING_CLI
    chewing-cli
    PATHS "C:\\Program Files\\ChewingTextService"
    REQUIRED
  )
endif()

include(GNUInstallDirs)

add_subdirectory(dict/chewing)
add_subdirectory(misc)

if(PROJECT_IS_TOP_LEVEL)
  set(CPACK_GENERATOR "ZIP")
  include(CPack)
endif()
