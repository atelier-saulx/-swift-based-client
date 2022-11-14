#!/bin/sh
set -e
if test "$CONFIGURATION" = "Debug"; then :
  cd /Users/francesco/saulx/based/packages/cpp-client/build_ios
  make -f /Users/francesco/saulx/based/packages/cpp-client/build_ios/CMakeScripts/ReRunCMake.make
fi
if test "$CONFIGURATION" = "Release"; then :
  cd /Users/francesco/saulx/based/packages/cpp-client/build_ios
  make -f /Users/francesco/saulx/based/packages/cpp-client/build_ios/CMakeScripts/ReRunCMake.make
fi
if test "$CONFIGURATION" = "MinSizeRel"; then :
  cd /Users/francesco/saulx/based/packages/cpp-client/build_ios
  make -f /Users/francesco/saulx/based/packages/cpp-client/build_ios/CMakeScripts/ReRunCMake.make
fi
if test "$CONFIGURATION" = "RelWithDebInfo"; then :
  cd /Users/francesco/saulx/based/packages/cpp-client/build_ios
  make -f /Users/francesco/saulx/based/packages/cpp-client/build_ios/CMakeScripts/ReRunCMake.make
fi

