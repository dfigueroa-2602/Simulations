cmake_minimum_required(VERSION 3.10)
project(CSI_Ccode LANGUAGES C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

message(STATUS "ALL_C_SOURCES = ${ALL_C_SOURCES}")

file(GLOB_RECURSE ALL_C_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.c")
add_library(CSI_Plecs SHARED ${ALL_C_SOURCES})

target_include_directories(CSI_Plecs
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)

set_target_properties(CSI_Plecs PROPERTIES
    OUTPUT_NAME "CSI_Plecs"
)