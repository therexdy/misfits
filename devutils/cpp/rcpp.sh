#!/usr/bin/env bash

set -e

ROOT_DIR="$(pwd)"
PROJECT_NAME=""
BUILD_TYPE=""
COMPILER=""
STATIC_LINK=0
DYNAMIC_LINK=0

find_sources() {
    find "$ROOT_DIR" -type f \( -name "*.cpp" -o -name "*.hpp" -o -name "*.h" -o -name "*.cc" \)
}

check_libs_compatibility() {
    for libfile in "$ROOT_DIR/libs/"*; do
        [[ -f "$libfile" ]] || continue
        ext="${libfile##*.}"
        case "$ext" in
            a|lib) libtype="STATIC" ;;
            so|dll|dylib) libtype="SHARED" ;;
            *) libtype="UNKNOWN" ;;
        esac
        if [[ -f "${libfile}.compiler" ]]; then
            libcomp=$(<"${libfile}.compiler")
            if [[ "$libcomp" != "$COMPILER" ]]; then
                echo "ERROR: Library $(basename "$libfile") was built with $libcomp, but you are using $COMPILER."
                echo "       Recommendation: rebuild the library with $COMPILER or switch compiler flag."
                exit 1
            fi
        fi
        if [[ "$STATIC_LINK" -eq 1 && "$libtype" != "STATIC" ]]; then
            echo "ERROR: Static linking requested, but library $(basename "$libfile") is not static ($ext)."
            echo "       Recommendation: use --release --dynamic or provide a static version of the library."
            exit 1
        fi
    done
}

setup_project() {
    local pname="$1"
    if [[ "$pname" == "." || -z "$pname" ]]; then
        PROJECT_NAME="$(basename "$ROOT_DIR")"
    else
        PROJECT_NAME="$pname"
        mkdir -p "$PROJECT_NAME"
        cd "$PROJECT_NAME"
        ROOT_DIR="$(pwd)"
    fi

    echo "Setting up project: $PROJECT_NAME"
    mkdir -p src include build/debug build/release libs

    cat > CMakeLists.txt <<EOF
cmake_minimum_required(VERSION 3.15)
project(${PROJECT_NAME} CXX)

set(CMAKE_CXX_COMPILER_DEBUG clang++)
set(CMAKE_C_COMPILER_DEBUG clang)

set(CMAKE_CXX_COMPILER_RELEASE g++)
set(CMAKE_C_COMPILER_RELEASE gcc)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG \${CMAKE_SOURCE_DIR}/build/debug)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE \${CMAKE_SOURCE_DIR}/build/release)

file(GLOB_RECURSE SRC_FILES CONFIGURE_DEPENDS src/*.cpp)
include_directories(include)

add_executable(${PROJECT_NAME} \${SRC_FILES})

# ---------------------------
# Link libraries
# ---------------------------
# Example: link library from libs/ (static or dynamic)
# add_subdirectory(libs/mylib)
# target_link_libraries(\${PROJECT_NAME} PRIVATE mylib)

# Or using find_package:
# find_package(SomeLib REQUIRED)
# target_link_libraries(\${PROJECT_NAME} PRIVATE SomeLib::SomeLib)
EOF

    echo "Project created."
}

build_project() {
    local build_dir build_type_flag
    if [[ "$BUILD_TYPE" == "Debug" ]]; then
        build_dir="$ROOT_DIR/build/debug"
        build_type_flag="-DCMAKE_BUILD_TYPE=Debug"
    else
        build_dir="$ROOT_DIR/build/release"
        build_type_flag="-DCMAKE_BUILD_TYPE=Release"
    fi

    check_libs_compatibility

    cmake_opts="$build_type_flag"
    if [[ "$STATIC_LINK" -eq 1 ]]; then
        cmake_opts+=" -DBUILD_SHARED_LIBS=OFF"
        cmake_opts+=" -DCMAKE_EXE_LINKER_FLAGS='-static'"
    elif [[ "$DYNAMIC_LINK" -eq 1 ]]; then
        cmake_opts+=" -DBUILD_SHARED_LIBS=ON"
    fi

    echo "Configuring project in $build_dir using $COMPILER"
    cmake -S "$ROOT_DIR" -B "$build_dir" $cmake_opts
    echo "Building project..."
    cmake --build "$build_dir" -- -j$(nproc)
    echo "$BUILD_TYPE build finished."
}

run_tidy() {
    echo "Running clang-tidy recursively..."
    for f in $(find_sources); do
        echo "Tidy: $f"
        clang-tidy "$f" -- -I"$ROOT_DIR/include"
    done
}

run_format() {
    echo "Running clang-format recursively..."
    for f in $(find_sources); do
        echo "Format: $f"
        clang-format -i "$f"
    done
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --setup)
            setup_project "$2"
            exit 0
            ;;
        --build)
            BUILD_TYPE="Debug"
            COMPILER="clang"
            STATIC_LINK=0
            shift
            ;;
        --release)
            BUILD_TYPE="Release"
            COMPILER="gcc"
            STATIC_LINK=1
            DYNAMIC_LINK=0
            shift
            ;;
        --gcc)
            COMPILER="gcc"
            shift
            ;;
        --static)
            STATIC_LINK=1
            DYNAMIC_LINK=0
            shift
            ;;
        --dynamic)
            DYNAMIC_LINK=1
            STATIC_LINK=0
            shift
            ;;
        --tidy)
            run_tidy
            exit 0
            ;;
        --format)
            run_format
            exit 0
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

if [[ -n "$BUILD_TYPE" ]]; then
    if [[ "$BUILD_TYPE" == "Release" ]]; then
        echo "Release build: optimization enabled, static linking by default"
    fi
    build_project
fi

