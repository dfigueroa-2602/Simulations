
cmake_minimum_required(VERSION 3.10)
project(VSI_Ccode LANGUAGES C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Collect all .c sources in src/
file(GLOB_RECURSE ALL_C_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.c")

# Exclude `main.c` from the library sources (if present)
list(FILTER ALL_C_SOURCES EXCLUDE REGEX ".*/main\.c$")

add_library(VSI_Plecs SHARED ${ALL_C_SOURCES})

target_include_directories(VSI_Plecs
	PUBLIC
		${CMAKE_CURRENT_SOURCE_DIR}/src
)

set_target_properties(VSI_Plecs PROPERTIES
	OUTPUT_NAME "VSI_Plecs"
)