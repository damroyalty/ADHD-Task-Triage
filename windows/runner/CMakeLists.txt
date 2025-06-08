cmake_minimum_required(VERSION 3.14) # Ensure this matches the parent CMakeLists.txt
project(runner LANGUAGES CXX)

# Explicitly set the MSVC runtime library for the runner as well.
# This section should be fine as it is, relying on CMAKE_BUILD_TYPE
if(NOT CMAKE_BUILD_TYPE OR (CMAKE_BUILD_TYPE STREQUAL "Release") OR (CMAKE_BUILD_TYPE STREQUAL "Profile") OR (CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo"))
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL" CACHE STRING "MSVC Runtime Library" FORCE)
else() # Debug
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDebugDLL" CACHE STRING "MSVC Runtime Library" FORCE)
endif()

add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)

apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Add dependency libraries and include directories.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib") # Keep standard Windows libs

# Explicitly link the MSVC C++ runtime import library to resolve vectorized algorithm symbols
if(MSVC)
  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_link_libraries(${BINARY_NAME} PRIVATE msvcprtd)
  else()
    target_link_libraries(${BINARY_NAME} PRIVATE msvcprt)
  endif()
endif()

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
