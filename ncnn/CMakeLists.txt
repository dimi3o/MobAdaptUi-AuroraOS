# SPDX-FileCopyrightText: 2023 Open Mobile Platform LLC <community@omp.ru>
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.5)

project(ncnn)

set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_SKIP_INSTALL_RPATH ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/ncnn)

set(NCNN_SHARED_LIB ON)
set(BUILD_PERF_TESTS OFF)
set(NCNN_AVXVNNI OFF)
set(NCNN_AVX512BF16 OFF)

add_subdirectory(ncnn)

