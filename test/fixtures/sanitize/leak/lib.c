#include <stdlib.h>

void *pointer;

void
leak_memory(void) {
  pointer = malloc(16);
  pointer = NULL;
}
