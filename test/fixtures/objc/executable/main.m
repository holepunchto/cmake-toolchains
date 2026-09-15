#import <Foundation/Foundation.h>

// `@available` lowers to a call to `__isPlatformVersionAtLeast()`, which lives
// in the compiler runtime library for the target platform. Linking this is what
// an LLVM without the runtime libraries for that platform cannot do.
int
main() {
  if (@available(macOS 14.0, iOS 15.0, *)) {
    return 0;
  }

  return 1;
}
