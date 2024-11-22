# good source https://izzys.casa/

# Content
# 0. Basic usage
# 1. pull googletest
# 2. external projects (antipattern, projects should provide direct commands)
# 3. lib + exe generation
# 4. use googletest
# 5. debugging
# 6. SHENNANIGAN

# 0. CMake is best used in the command line.
# Example `set(CMAKE_BUILD_TYPE "Release" CACHE STRING FORCE)` required for debugging symbols.
# In cmdline `cmake -DCMAKE_BUILD_TYPE="Debug"` # or `RelWithDebInfo` is sufficient.
# See also https://github.com/mfussenegger/nvim-dap/wiki/Debug-symbols-in-various-languages-and-build-systems

# 1. NOTE: google plans to package an even bigger test library, which adds
# addition link time => dont use it, if you want fast CI or use the test library
# in a REPL.
cmake_minimum_required(VERSION 3.10)
# GOOGLETEST: Download and unpack
include(FetchContent)
FetchContent_Declare(
  googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG        e2239ee6043f73722e7aa812a459f54a28552929
)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)


project(myCoolProject)
set(CMAKE_CXX_STANDARD 17)
#set(CMAKE_BUILD_TYPE "Debug")

# 2. external projects
include(ExternalProject)
ExternalProject_Add(project
    PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/extern/project
    GIT_REPOSITORY git@github.com:organization/project.git
    # fixed git tag to prevent fetching for updates
    GIT_TAG be0eada58d3ea48c6af22e674375fb1c54ab78ee
    #CMAKE_ARGS
        # DONT DO THIS. Cmake has weird commands to force debug
        # set(CMAKE_BUILD_TYPE "Release" CACHE STRING FORCE) is required
        #-DCMAKE_BUILD_TYPE=Debug
        #-DARCADE_LOG_FORCE_DEBUG_LOGGING_ON=ON
    BUILD COMMAND make project.component
    INSTALL COMMAND ""
    )

# 3. lib + exe generation
if(WIN32)
  set(PROJECT_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/extern/arcade/src/arcade-build/core/")
  set(prefix "")
  set(suffix ".lib")
elseif(APPLE)
  set(PROJECT_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/extern/arcade/src/arcade-build/core/")
  set(prefix "lib")
  set(suffix ".a")
else()
  set(PROJECT_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/extern/arcade/src/arcade-build/core/")
  set(prefix "lib")
  set(suffix ".a")
endif()
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/extern/project/component")

set(PROJECT_LIBRARIES
  "${ARCADE_LIB_DIR}/${prefix}arcade.core_r${suffix}")
#include_directories("src/your_addon")
#add_library(your_addon STATIC "src/project_add/file1.h"
                               "src/project_add/file1.cpp")

add_dependencies(project_addon project your_addon)

include_directories("src/lib")
add_library(yourcoollib STATIC "src/lib/file1.h" "src/lib/file2.cpp")
add_dependencies(yourcoollib project_addon)

add_executable(appname "src/app/yourapp.cpp")
add_dependencies(appname project_addon yourcoollib)

# googletest (gtest_main is the provided lib)
add_executable(test1 "tst/test_comp1.cpp")
add_dependencies(test1 project_addon yourcoollib)
target_link_libraries(test1 gtest_main yourcoollib project_addon ${PROJECT_LIBRARIES})
add_test(NAME test1 COMMAND test1)


# 5. Debugging
# --trace,  --trace-expand, --debug-output, --debug-trycompile
# And check the created log files.
# run cmake with -LH to get all variables printed after configuration.

# function(PRINT_VAR VARNAME)
#   message(STATUS "${VARNAME}: ${${VARNAME}}")
# endfunction()
# PRINT_VAR("CMAKE_CXX_COMPILER")

# cmake -P to run a single script

# 6. SHENNANIGAN
# As of cmake v3.26.5
# To get only the used file paths, we must use --trace-format=json-v1
# and extract field 'file' from each returned json
# Compare this to 'ninja -d explain' or 'ninja -v' printing the reasons and commands.