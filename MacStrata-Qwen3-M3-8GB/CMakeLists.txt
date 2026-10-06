cmake_minimum_required(VERSION 3.20)
project(MacStrataQwen3 VERSION 0.1.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_library(macstrata STATIC macstrata/expert_manager.cpp)
target_include_directories(macstrata PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/macstrata)
target_compile_options(macstrata PRIVATE -Wall -Wextra -Wpedantic)

add_executable(macstrata_sim macstrata/main.cpp)
target_link_libraries(macstrata_sim PRIVATE macstrata)

include(CTest)
if(BUILD_TESTING)
  add_executable(macstrata_tests tests/test_expert_manager.cpp)
  target_link_libraries(macstrata_tests PRIVATE macstrata)
  add_test(NAME macstrata_tests COMMAND macstrata_tests)
endif()
