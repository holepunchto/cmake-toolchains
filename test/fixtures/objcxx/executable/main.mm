#import <Foundation/Foundation.h>

int
main() {
  if (@available(macOS 14.0, iOS 15.0, *)) {
    return 0;
  }

  return 1;
}
