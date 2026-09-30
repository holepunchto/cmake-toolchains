cmake_minimum_required(VERSION 3.25)

project(external_project C)

include(ExternalProject)

ExternalProject_Add(
  subproject
  SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/subproject"
  CMAKE_ARGS
    "-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}"
    "-DEXPECTED_C_COMPILER=${CMAKE_C_COMPILER}"
  INSTALL_COMMAND ""
)
