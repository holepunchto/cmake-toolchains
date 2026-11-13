#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int
main(int argc, char *argv[]) {
  if (argc != 3) return 1;

  if (strcmp(argv[1], "print") == 0) {
    puts(argv[2]);

    return 0;
  }

  if (strcmp(argv[1], "exit") == 0) return atoi(argv[2]);

  if (strcmp(argv[1], "abort") == 0) abort();

  if (strcmp(argv[1], "alloc") == 0) {
    char *memory = malloc(strtoul(argv[2], NULL, 0));

    if (memory == NULL) return 1;

    memory[0] = 1;

    free(memory);

    return 0;
  }

  return 1;
}
