void
leak_memory(void);

int
main(int argc, char *argv[]) {
  leak_memory();
  return 0;
}
