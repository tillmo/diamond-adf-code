cmake_minimum_required(VERSION 3.1)
project(DIAMOND)

# version number:
set(DIAMOND_VERSION_MAJOR 3)
set(DIAMOND_VERSION_MINOR 0)
set(DIAMOND_VERSION_BUILD 1)

# Compiler Flags
# TODO: handle ASIO_HAS_CLANG_LIBCXX (e.g. add with boost option)
set(CXX_FLAGS "-std=c++14 -DWITH_THREADS=1")
set(CXX_FLAGS_DEBUG "-DDEBUG_BUILD -Wall")
set(CMAKE_CXX_FLAGS "${CXX_FLAGS}")
set(CMAKE_CXX_FLAGS_DEBUG "${CXX_FLAGS} ${CXX_FLAGS_DEBUG}")
set(CMAKE_CXX_FLAGS_RELEASE "${CXX_FLAGS}")


# DIAMOND sources and headers (incl shipped libraries)
set(DIAMOND_SRC "src")
set(DIAMOND_CONF "${PROJECT_BINARY_DIR}/include")
set(DIAMOND_INCLUDE "include"
                    "${DIAMOND_CONF}")

configure_file(
  "${DIAMOND_SRC}/diamond/config.h.cmake"
  "${DIAMOND_CONF}/diamond/config.h")

# LibClingo
LIST(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/modules")
set(CLINGO_BUILDDIR "/local/sfbuild/clingo")
find_package(LibClingo REQUIRED)
INCLUDE_DIRECTORIES(${LIBCLINGO_INCLUDE_DIRS})

# QT5 stuff
set(CMAKE_AUTOMOC true)
find_package(Qt5Core REQUIRED)
INCLUDE_DIRECTORIES(${Qt5Core_INCLUDES})

INCLUDE_DIRECTORIES(${DIAMOND_INCLUDE})
set(DIAMOND_CPP ${DIAMOND_SRC}/main.cpp
                ${DIAMOND_SRC}/diamond/UsageOutput.cpp
                ${DIAMOND_SRC}/diamond/AppOptions.cpp
                ${DIAMOND_SRC}/diamond/semantics/ISemantics.cpp
                ${DIAMOND_SRC}/diamond/semantics/Model.cpp)

# generate header-locations for qtcreator
if(DIAMOND_QTCREATOR)
file(GLOB DIAMOND_HEADERS "include/*.hpp" "include/diamond/*.hpp" "include/diamond/*/*.hpp")
add_executable(diamond ${DIAMOND_CPP} ${DIAMOND_HEADERS})
else()
add_executable(diamond ${DIAMOND_CPP})
endif()

target_link_libraries(diamond ${Qt5Core_LIBRARIES} ${LIBCLINGO_LIBRARY})
