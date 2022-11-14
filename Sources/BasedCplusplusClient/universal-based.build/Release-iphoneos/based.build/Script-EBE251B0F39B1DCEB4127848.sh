#!/bin/sh
set -e
if test "$CONFIGURATION" = "Debug"; then :
  cd /Users/francesco/saulx/based/packages/cpp-client/build_ios
  /usr/local/Cellar/cmake/3.24.0/bin/cmake -E cmake_symlink_library /Users/francesco/saulx/based/packages/cpp-client/build_ios/Debug${EFFECTIVE_PLATFORM_NAME}/libbased.dylib /Users/francesco/saulx/based/packages/cpp-client/build_ios/Debug${EFFECTIVE_PLATFORM_NAME}/libbased.dylib /Users/francesco/saulx/based/packages/cpp-client/build_ios/Debug${EFFECTIVE_PLATFORM_NAME}/libbased.dylib
fi
if test "$CONFIGURATION" = "Release"; then :
  cd /Users/francesco/saulx/based/packages/cpp-client/build_ios
  /usr/local/Cellar/cmake/3.24.0/bin/cmake -E cmake_symlink_library /Users/francesco/saulx/based/packages/cpp-client/build_ios/Release${EFFECTIVE_PLATFORM_NAME}/libbased.dylib /Users/francesco/saulx/based/packages/cpp-client/build_ios/Release${EFFECTIVE_PLATFORM_NAME}/libbased.dylib /Users/francesco/saulx/based/packages/cpp-client/build_ios/Release${EFFECTIVE_PLATFORM_NAME}/libbased.dylib
fi
if test "$CONFIGURATION" = "MinSizeRel"; then :
  cd /Users/francesco/saulx/based/packages/cpp-client/build_ios
  /usr/local/Cellar/cmake/3.24.0/bin/cmake -E cmake_symlink_library /Users/francesco/saulx/based/packages/cpp-client/build_ios/MinSizeRel${EFFECTIVE_PLATFORM_NAME}/libbased.dylib /Users/francesco/saulx/based/packages/cpp-client/build_ios/MinSizeRel${EFFECTIVE_PLATFORM_NAME}/libbased.dylib /Users/francesco/saulx/based/packages/cpp-client/build_ios/MinSizeRel${EFFECTIVE_PLATFORM_NAME}/libbased.dylib
fi
if test "$CONFIGURATION" = "RelWithDebInfo"; then :
  cd /Users/francesco/saulx/based/packages/cpp-client/build_ios
  /usr/local/Cellar/cmake/3.24.0/bin/cmake -E cmake_symlink_library /Users/francesco/saulx/based/packages/cpp-client/build_ios/RelWithDebInfo${EFFECTIVE_PLATFORM_NAME}/libbased.dylib /Users/francesco/saulx/based/packages/cpp-client/build_ios/RelWithDebInfo${EFFECTIVE_PLATFORM_NAME}/libbased.dylib /Users/francesco/saulx/based/packages/cpp-client/build_ios/RelWithDebInfo${EFFECTIVE_PLATFORM_NAME}/libbased.dylib
fi

