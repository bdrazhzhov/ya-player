cmake_minimum_required(VERSION 3.12)
project(context-menu-manager)

set(CMAKE_CXX_STANDARD 20)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK3 REQUIRED gtk+-3.0)

find_package(Fontconfig)

add_library(${PROJECT_NAME} OBJECT context-menu.cpp)

target_include_directories(${PROJECT_NAME} PRIVATE ${GTK3_INCLUDE_DIRS})
target_compile_options(${PROJECT_NAME} PRIVATE ${GTK3_CFLAGS_OTHER})
target_link_libraries(${PROJECT_NAME} PRIVATE ${GTK3_LIBRARIES} Fontconfig::Fontconfig)
