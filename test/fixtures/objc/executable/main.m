#import <Foundation/Foundation.h>

// `@available` calls into the compiler runtime library for the target platform.
int
main() {
  if (@available(macOS 14.0, iOS 15.0, *)) {
    return 0;
  }

  return 1;
}
