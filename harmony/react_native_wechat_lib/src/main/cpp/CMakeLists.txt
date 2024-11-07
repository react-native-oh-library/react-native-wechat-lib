# the minimum version of CMake.
cmake_minimum_required(VERSION 3.13)
set(CMAKE_VERBOSE_MAKEFILE on)

set(rnoh_wechat_lib_generated_dir "${CMAKE_CURRENT_SOURCE_DIR}/generated")
file(GLOB_RECURSE rnoh_wechat_lib_generated_SRC "${rnoh_wechat_lib_generated_dir}/**/*.cpp")
file(GLOB rnoh_wechat_lib_SRC CONFIGURE_DEPENDS *.cpp)
add_library(wechat_lib SHARED ${rnoh_wechat_lib_SRC} ${rnoh_wechat_lib_generated_SRC})
target_include_directories(wechat_lib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR} ${rnoh_wechat_lib_generated_dir})
target_link_libraries(wechat_lib PUBLIC rnoh)
