#include <limits.h>

int
add(int a, int b);

int
main(int argc, char *argv[]) {
  return add(INT_MAX, argc) == 0;
}
