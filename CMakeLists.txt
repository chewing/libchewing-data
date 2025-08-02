cmake_minimum_required(VERSION 3.31.6...3.31.6)
project(libchewing-data LANGUAGES NONE)

option(USE_SYSTEM_CHEWING_CLI "Use system-installed chewing-cli instead of building from source" ON)

if(USE_SYSTEM_CHEWING_CLI)
  find_program(CHEWING_CLI
    chewing-cli
    PATHS "C:\\Program Files\\ChewingTextService"
    REQUIRED
  )
endif()

add_subdirectory(dict/chewing)
add_subdirectory(misc)
